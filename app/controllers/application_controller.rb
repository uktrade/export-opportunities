require 'yaml'

class ApplicationController < ActionController::Base
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

  def set_no_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store'
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
  helper_method :opportunity_index_exists?

  layout :determine_layout

  def check
    # if we cant query the existence of the index in ElasticSearch, its down

    if opportunity_index_exists?
      render json: { status: 'OK' }, status: :ok
    else
      render json: { status: 'NOTOK' }, status: :internal_server_error
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

  def determine_layout
    return 'admin' if request.path.start_with?('/admin') && staff?

    'application'
  end

  def require_sso!
    if current_user
      if Figaro.env.bypass_sso? || user_completed_new_registration_journey?
        return
      else
        sign_out current_user
      end
    end

    # So omniauth can return us where we left off
    store_location_for(:user, request.url)

    if Figaro.env.bypass_sso?
      redirect_to user_developer_omniauth_authorize_path
    else
      redirect_to user_exporting_is_great_omniauth_authorize_path
    end
  end

  def user_completed_new_registration_journey?
    return true if Figaro.env.bypass_sso?
    
    if (sso_data = DirectoryApiClient.user_data(cookies[Figaro.env.SSO_SESSION_COOKIE]))
      profile = value_by_key(sso_data, :user_profile)
      if profile.present?
        return true
      end
    end
    false
  end

  def value_by_key(hash, key)
    hash[key.to_s] || hash[key.to_sym]
  end

  def opps_counter_stats
    @redis ||= Redis.new(url: Figaro.env.redis_url)

    counter_opps_expiring_soon = @redis.get(:opps_counters_expiring_soon)
    counter_opps_total = @redis.get(:opps_counters_total)
    counter_opps_published_recently = @redis.get(:opps_counters_published_recently)

    { total: counter_opps_total.to_i, expiring_soon: counter_opps_expiring_soon.to_i, published_recently: counter_opps_published_recently.to_i }
  end

  def opportunity_index_exists?
    begin
      Opportunity.__elasticsearch__.client.indices.exists? index: Opportunity.index_name
    rescue Faraday::ConnectionFailed, TimeoutError
      return false
    end
    true
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
        format.html { render 'errors/not_found', status: :not_found }
        format.json { render json: { errors: 'Resource not found' }, status: :not_found }
        format.all { head 404 }
      end
    end

    def unsupported_format
      respond_to do |format|
        format.json { render json: { errors: 'JSON is not supported for this resource' }, status: :not_acceptable }
        format.all { head 406 }
      end
    end

    def user_not_authorized
      render 'errors/unauthorized', status: :unauthorized
    end

    def internal_server_error
      render 'errors/internal_server_error', status: :internal_server_error
    end

    def invalid_authenticity_token(exception)
      Raven.capture_exception(exception)
      set_google_tag_manager
      # ^ this method call is necessary to render
      #   the layout. It is usually run in a before_action.
      # The exception this method rescues from is thrown
      # before it has the chance.
      render 'errors/invalid_authenticity_token', status: :unprocessable_entity
    end

    # Returns content provided by .yml files in app/content folder.
    # Intended use is to keep content separated from the view code.
    # Should make it easier to switch later to CMS-style content editing.
    # Note: Rails may already provide a similar service for multiple
    # language support, so this mechanism might be replaced by that
    # at some point in the furture.
    def get_content(*files)
      content = {}
      files.each do |file|
        content = content.merge YAML.load_file('app/content/' + file)
      end
      content
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
