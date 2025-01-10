class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  def not_found
    super
    
    Sentry.capture_exception(ActionController::RoutingError.new('page not found'))
  end

  def internal_server_error
    super
  end
end
