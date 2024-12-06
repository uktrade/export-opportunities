class Admin::BaseController < ApplicationController
  include Pundit
  after_action :verify_authorized

  before_action :authenticate_editor!
  before_action :sign_out_if_deactivated!
  before_action :set_sentry_context
  before_action :set_no_cache_headers

  layout 'admin'

  def pundit_user
    current_editor
  end

  # https://github.com/airblade/paper_trail#4a-finding-out-who-was-responsible-for-a-change
  def user_for_paper_trail
    current_editor.id
  end

  private

    def sign_out_if_deactivated!
      # redirect_to new_editor_session_path unless current_editor
      if current_editor&.deactivated?
        sign_out(current_editor)
        redirect_to new_editor_session_path
      end
    end

    def set_sentry_context
      Sentry.set_user(user_id: current_editor.id, email: current_editor.email) if current_editor
      Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
    end
end
