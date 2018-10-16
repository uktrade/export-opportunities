class ApplicationController < ActionController::Base
  require 'yaml'
  # for how many days should we notify pingdom that a volume opps job has failed
  PUBLISH_SIDEKIQ_ERROR_DAYS = 1.freeze

  # Protect by basic auth on staging
  # Use basic auth if set in the environment
  before_action :basic_auth, except: :check

  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_authenticity_token

  def basic_auth
    return unless Figaro.env.staging_http_user? && Figaro.env.staging_http_pass?
    authenticate_or_request_with_http_basic do |name, password|
      name == Figaro.env.staging_http_user && password == Figaro.env.staging_http_pass
    end
  end

  before_action :set_google_tag_manager

  def set_google_tag_manager
    @google_tag_manager = if Figaro.env.google_tag_manager_keys?
                            Figaro.env.google_tag_manager_keys.split(',').map(&:strip)
                          else
                            []
                          end
  end

  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::UnknownFormat, with: :unsupported_format
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :administrator?
  helper_method :previewer?
  helper_method :publisher?
  helper_method :uploader?
  helper_method :staff?

  layout :determine_layout

  def check
    render json: { status: 'OK' }, status: 200
  end

  # basic checks for data sync between ES and PG DB
  def data_sync_check
    @redis ||= Redis.new(url: Figaro.env.redis_url)
    res = {}

    # opps that have not expired and are published
    db_opportunities_ids = db_opportunities
    sort = OpenStruct.new(column: :response_due_on, order: :desc)
    query = OpportunitySearchBuilder.new(search_term: '', sort: sort, dit_boost_search: false).call
    es_opportunities_ids = es_opportunities(query)

    res_opportunities_count = db_opportunities_ids.size == es_opportunities_ids.size
    if db_opportunities_ids.size != es_opportunities_ids.size
      missing_docs = db_opportunities_ids - es_opportunities_ids | es_opportunities_ids - db_opportunities_ids
      Rails.logger.error('we are missing opportunities docs')
      Rails.logger.error(missing_docs)
      res['opportunities'] = { expected_opportunities: db_opportunities_ids.size, actual_opportunities: es_opportunities_ids.size, missing: missing_docs }
    end

    db_subscriptions_ids = db_subscriptions
    es_subscriptions_ids = es_subscriptions

    res_subscriptions_count = db_subscriptions_ids.size == es_subscriptions_ids.size
    if db_subscriptions_ids.size != es_subscriptions_ids.size
      missing_docs = db_subscriptions_ids - es_subscriptions_ids | es_subscriptions_ids - db_subscriptions_ids
      Rails.logger.error('we are missing subscriber docs')
      Rails.logger.error(missing_docs)
      res['subscriptions'] = { expected_opportunities: db_subscriptions_ids.size, actual_opportunities: es_subscriptions_ids.size, missing: missing_docs }
    end

    result = res_opportunities_count && res_subscriptions_count
    case result
    when true
      # unset the counter when data is back in sync
      @redis.del(:es_data_sync_error_ts)
      render json: { git_revision: ExportOpportunities::REVISION, status: 'OK', result: res }, status: 200
    else
      previous_state = @redis.get(:es_data_sync_error_ts)
      timeout_seconds = (Time.now.utc - Time.zone.parse(previous_state)).floor if previous_state
      # if we found an error and it's more than 10 minutes since we found it, report the error

      if previous_state && timeout_seconds > report_es_data_sync_timeout
        return render json: { git_revision: ExportOpportunities::REVISION, status: 'error', timeout_sec: timeout_seconds, result: res }, status: 500
      end
      # first time we see an error
      @redis.set(:es_data_sync_error_ts, Time.now.utc) unless previous_state
      # keep reporting OK for pingdom, show the error in result field
      render json: { git_revision: ExportOpportunities::REVISION, status: 'OK', timeout_sec: timeout_seconds, result: res }, status: 200
    end
  end

  def api_check
    @redis ||= Redis.new(url: Figaro.env.redis_url)

    latest_sidekiq_failure = @redis.get(:sidekiq_retry_jobs_last_failure)

    sidekiq_retry_jobs_count = sidekiq_retry_count
    retry_count = redis_oo_retry_count(@redis)

    update_redis_counter(@redis, sidekiq_retry_jobs_count, latest_sidekiq_failure)

    # calculate counters
    today_date = Time.zone.now
    volume_opps = Opportunity.where(source: :volume_opps)
    daily_count = volume_opps.where('created_at>?', today_date.strftime('%Y-%m-%d')).count
    weekly_count = volume_opps.where('created_at>?', (today_date - 7.days).strftime('%Y-%m-%d')).count
    monthly_count = volume_opps.where('created_at>?', (today_date - 30.days).strftime('%Y-%m-%d')).count

    trashed_daily_count = volume_opps.where('created_at>?', today_date.strftime('%Y-%m-%d')).where(status: 4).count
    trashed_weekly_count = volume_opps.where('created_at>?', (today_date - 7.days).strftime('%Y-%m-%d')).where(status: 4).count
    trashed_monthly_count = volume_opps.where('created_at>?', (today_date - 30.days).strftime('%Y-%m-%d')).where(status: 4).count

    pending_daily_count = volume_opps.where('created_at>?', today_date.strftime('%Y-%m-%d')).where(status: 1).count
    pending_weekly_count = volume_opps.where('created_at>?', (today_date - 7.days).strftime('%Y-%m-%d')).where(status: 1).count
    pending_monthly_count = volume_opps.where('created_at>?', (today_date - 30.days).strftime('%Y-%m-%d')).where(status: 1).count

    azure_list_id = Figaro.env.AZ_CUSTOM_LIST_ID
    azure_az_api_key = "...#{Figaro.env.AZ_API_KEY[-4..-1]}"

    counter_opps_expiring_soon = @redis.get(:opps_counters_expiring_soon)
    counter_opps_total = @redis.get(:opps_counters_total)
    counter_opps_published_recently = @redis.get(:opps_counters_published_recently)

    volume_opps_failed_timestamp = @redis.get(:application_error)&.strip

    if (sidekiq_retry_jobs_count - retry_count).positive? && days_since_last_failure(latest_sidekiq_failure) < PUBLISH_SIDEKIQ_ERROR_DAYS
      render json: { status: 'error', retry_error_count: sidekiq_retry_jobs_count }
    else
      render json: { status: 'OK', fetched: { daily: daily_count, weekly: weekly_count, thirty_days: monthly_count }, trashed: { daily: trashed_daily_count, weekly: trashed_weekly_count, thirty_days: trashed_monthly_count }, pending: { daily: pending_daily_count, weekly: pending_weekly_count, thirty_days: pending_monthly_count }, api_config: { list_id: azure_list_id, api_key: azure_az_api_key }, opportunities_counters: { total: counter_opps_total, expiring_soon: counter_opps_expiring_soon, published_recently: counter_opps_published_recently }, latest_application_error: volume_opps_failed_timestamp }
    end
  end

  def db_opportunities
    Opportunity.where('response_due_on >= ? and status = ?', DateTime.now.utc, 2).pluck(:id)
  end

  def es_opportunities(query)
    res = []
    es_opportunities = Opportunity.__elasticsearch__.search(size: 100_000, query: query[:search_query], sort: query[:search_sort])
    es_opportunities.each { |record| res.push record.id }
    res
  end

  def db_subscriptions
    Subscription.count
  end

  def es_subscriptions
    Subscription.__elasticsearch__.count
  end

  def determine_layout
    return 'admin' if request.path.start_with?('/admin') && staff?
    'application'
  end

  def require_sso!
    return if current_user

    # So omniauth can return us where we left off
    store_location_for(:user, request.url)

    if Figaro.env.bypass_sso?
      redirect_to user_developer_omniauth_authorize_path
    else
      redirect_to user_exporting_is_great_omniauth_authorize_path
    end
  end

  def opps_counter_stats
    @redis ||= Redis.new(url: Figaro.env.redis_url)

    counter_opps_expiring_soon = @redis.get(:opps_counters_expiring_soon)
    counter_opps_total = @redis.get(:opps_counters_total)
    counter_opps_published_recently = @redis.get(:opps_counters_published_recently)

    { total: counter_opps_total.to_i, expiring_soon: counter_opps_expiring_soon.to_i, published_recently: counter_opps_published_recently.to_i }
  end

  def report_es_data_sync_timeout
    600.freeze
  end

  private

  def administrator?
    current_editor&.administrator?
  end

  def previewer?
    current_editor&.previewer?
  end

  def publisher?
    current_editor&.publisher?
  end

  def uploader?
    current_editor&.uploader?
  end

  def staff?
    current_editor&.staff?
  end

  def check_if_admin
    not_found unless administrator?
  end

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: 404 }
      format.json { render json: { errors: 'Resource not found' }, status: 404 }
      format.all { head 404 }
    end
  end

  def unsupported_format
    respond_to do |format|
      format.json { render json: { errors: 'JSON is not supported for this resource' }, status: 406 }
      format.all { head 406 }
    end
  end

  def user_not_authorized
    render 'errors/unauthorized', status: 401
  end

  def internal_server_error
    render 'errors/internal_server_error', status: 500
  end

  def invalid_authenticity_token(exception)
    Raven.capture_exception(exception)
    set_google_tag_manager
    # ^ this method call is necessary to render
    #   the layout. It is usually run in a before_action.
    # The exception this method rescues from is thrown
    # before it has the chance.
    render 'errors/invalid_authenticity_token', status: 422
  end

  # Returns content provided by .yml files in app/content folder.
  # Intended use is to keep content separated from the view code.
  # Should make it easier to switch later to CMS-style content editing.
  # Note: Rails may already provide a similar service for multiple
  # language support, so this mechanism might be replaced by that
  # at some point in the furture.
  def get_content(file)
    YAML.load_file('app/content/' + file)
  end

  def redis_oo_retry_count(redis)
    # nil-safe redis fetch from counter
    redis.get('oo_retry_error_count').to_i
  end

  def sidekiq_retry_count
    rs = Sidekiq::RetrySet.new
    retry_jobs = rs.select { |retri| retri.item['class'] == 'RetrieveVolumeOpps' }
    retry_jobs.size
  end

  def update_redis_counter(redis, sidekiq_retry_jobs_count, latest_sidekiq_failure)
    # set initial value if it's the first time
    redis.set('sidekiq_retry_jobs_last_failure', Time.zone.now) unless latest_sidekiq_failure

    if days_since_last_failure(latest_sidekiq_failure) > PUBLISH_SIDEKIQ_ERROR_DAYS
      redis.set('oo_retry_error_count', sidekiq_retry_jobs_count)
      redis.set('sidekiq_retry_jobs_last_failure', Time.zone.now)
    end
  end

  def days_since_last_failure(latest_sidekiq_failure)
    return 0 unless latest_sidekiq_failure
    ((Time.zone.now - Time.zone.parse(latest_sidekiq_failure)) / 86_400)
  end
end
