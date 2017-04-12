class V1::BaseController < ApplicationController
  skip_before_action :authenticate_editor!
  protect_from_forgery with: :null_session

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  def not_found
    render json: { errors: 'requested resource not found' }, status: :not_found
  end

  def render_error(message, status)
    render json: { errors: message }, status: status
  end
end
