# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController # :nodoc:
    include Pundit

    after_action :verify_authorized
    before_action :authenticate_editor!
    before_action :sign_out_if_deactivated!
    before_action :set_raven_context
    before_action :set_no_cache_headers

    layout 'admin'

    def pundit_user
      current_editor
    end

    # https://github.com/airblade/paper_trail#4a-finding-out-who-was-responsible-for-a-change
    def user_for_paper_trail
      current_editor.id
    end

    def logged_in?
      current_editor.present? && token_valid?
    end
    helper_method :logged_in?

    def token_valid?
      token_expires_at = session[:expires_at]
      return false if token_expires_at.blank?

      token_expires_at > Time.current.to_i
    end
    helper_method :token_valid?

    def authenticate_editor!
      redirect_to admin_new_editor_session_path unless logged_in?
    end

    def current_editor
      uid = session[:uid]
      return nil if uid.blank?

      @current_editor ||= Editor.find_by(uid: uid)
    rescue ActiveRecord::RecordNotFound
      session.destroy
    end
    helper_method :current_editor

    def admin_logout_path
      "#{Figaro.env.STAFF_SSO_PROVIDER}/logout?next=#{root_url}"
    end
    helper_method :admin_logout_path

    private

    def sign_out_if_deactivated!
      # redirect_to admin_new_editor_session_path unless current_editor
      return unless current_editor&.deactivated?

      sign_out(current_editor)
      redirect_to admin_new_editor_session_path
    end

    def set_raven_context
      Raven.user_context(user_id: current_editor.id, email: current_editor.email) if current_editor
      Raven.extra_context(params: params.to_unsafe_h, url: request.url)
    end
  end
end
