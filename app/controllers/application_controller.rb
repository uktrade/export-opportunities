class ApplicationController < ActionController::Base
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
    res = {}

    # opps that have not expired and are published
    # db_opportunities = get_db_opportunities
    db_opportunities_ids = db_opportunities
    sort = OpenStruct.new(column: :response_due_on, order: :desc)
    query = OpportunitySearchBuilder.new(search_term: '', sort: sort).call
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
      render json: { git_revision: ExportOpportunities::REVISION, status: 'OK', result: res }, status: 200
    else
      render json: { git_revision: ExportOpportunities::REVISION, status: 'error', result: res }, status: 500
    end
  end

  def db_opportunities
    Opportunity.where('response_due_on >= ? and status = ?', DateTime.now.utc, 2).pluck(:id)
  end

  def es_opportunities(query)
    res = []
    es_opportunities = Opportunity.__elasticsearch__.search(size: 10_000, query: query[:search_query], sort: query[:search_sort])
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
      format.all { render status: 404, nothing: true }
    end
  end

  def unsupported_format
    respond_to do |format|
      format.json { render json: { errors: 'JSON is not supported for this resource' }, status: 406 }
      format.all { render status: 406, nothing: true }
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
end
