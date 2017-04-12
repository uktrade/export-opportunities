class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def not_found
    super
  end

  def internal_server_error
    super
  end
end
