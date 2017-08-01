class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def not_found
    super
    Raven.capture_exception('page not found')
  end

  def internal_server_error
    super
  end
end
