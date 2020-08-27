# frozen_string_literal: true

module Admin
  class SessionsController < Admin::BaseController # :nodoc:
    skip_after_action :verify_authorized
    skip_before_action :authenticate_editor!
    skip_before_action :sign_out_if_deactivated!
    skip_before_action :set_raven_context

    def create
      auth = request.env['omniauth.auth']

      session[:uid] = Editor.from_omniauth(auth).uid
      session[:expires_at] = auth.credentials.expires_at

      redirect_to admin_root_path
    end

    def destroy
      session.destroy
      redirect_to admin_logout_path
    end
  end
end
