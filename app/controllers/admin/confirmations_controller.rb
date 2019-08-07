# https://github.com/plataformatec/devise/wiki/How-To:-Override-confirmations-so-users-can-pick-their-own-passwords-as-part-of-confirmation-activation

class Admin::ConfirmationsController < Devise::ConfirmationsController
  # Remove the first skip_before_filter (:require_no_authentication) if you
  # don't want to enable logged in users to access the confirmation page.
  skip_before_action :require_no_authentication, raise: false
  skip_before_action :authenticate_editor!, raise: false
  before_action :set_no_cache_headers

  # PUT /resource/confirmation
  def update
    with_unconfirmed_editor do
      if @editor.confirmed_at.nil?
        @editor.attempt_set_password(params[:editor])
        if @editor.valid? && @editor.password_match?
          do_confirm
        else
          do_show
          @editor.errors.clear # so that we wont render :new
        end
      else
        @editor.errors.add(:email, :password_already_set)
      end
    end

    return if @editor.errors.empty?

    self.resource = @editor
    render 'admin/confirmations/show' # Changed from devise path to our custom path
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    with_unconfirmed_editor do
      if @editor.confirmed_at.nil?
        do_show
      else
        do_confirm
      end
    end

    unless @editor.errors.empty?
      self.resource = @editor
      render 'admin/confirmations/show' # Changed from devise path to our custom path
    end
  end

  protected

    def with_unconfirmed_editor
      @editor = Editor.find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
      @editor.only_if_unconfirmed { yield } unless @editor.new_record?
    end

    def do_show
      @requires_password = true
      set_minimum_password_length
      render 'admin/confirmations/show' # Changed from devise path to our custom path
    end

    def do_confirm
      @editor.confirm
      set_flash_message :notice, :confirmed
      sign_in(@editor)
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    end

  private

    def editor_confirmation_token
      params.require(:editor).require(:confirmation_token)
    end

    def confirmation_token
      params.fetch(:confirmation_token) { editor_confirmation_token }
    end

    def after_confirmation_path_for(_resource_name, _resource)
      admin_opportunities_path
    end
end
