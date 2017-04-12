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
    if Figaro.env.google_tag_manager_keys?
      @google_tag_manager = Figaro.env.google_tag_manager_keys.split(',').map(&:strip)
    else
      @google_tag_manager = []
    end
  end

  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::UnknownFormat, with: :unsupported_format
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :administrator?
  helper_method :staff?

  layout :determine_layout

  def check
    render json: { status: 'OK' }, status: 200
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
      redirect_to user_omniauth_authorize_path(:developer)
    else
      redirect_to user_omniauth_authorize_path(:exporting_is_great)
    end
  end

  private

  def administrator?
    current_editor&.administrator?
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
