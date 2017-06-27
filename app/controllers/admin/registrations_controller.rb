class Admin::RegistrationsController < Devise::RegistrationsController
  include Pundit
  after_action :verify_authorized
  before_action :configure_permitted_parameters
  before_action :load_service_providers

  skip_before_action :require_no_authentication

  rescue_from Pundit::NotAuthorizedError, with: :not_found

  layout 'admin'

  # GET /resource/sign_up
  def new
    super do |resource|
      authorize resource
    end
  end

  # POST /resource
  def create
    super do |resource|
      authorize resource
      resource.password = SecureRandom.hex(64)
      resource.save
    end
  end

  # https://github.com/plataformatec/devise/wiki/How-to:-Soft-delete-a-user-when-user-deletes-account
  def destroy
    resource = Editor.find(params.require(:id))
    authorize resource
    resource.soft_delete
    set_flash_message :notice, :destroyed if is_flashing_format?
    redirect_to admin_editors_path
  end

  def reactivate
    resource = Editor.find(params.require(:id))
    authorize resource
    resource.deactivated_at = nil
    resource.save!
    set_flash_message :notice, :reactivated if is_flashing_format?
    redirect_to admin_editors_path
  end

  private def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:sign_up) << :role
    devise_parameter_sanitizer.for(:sign_up) << :service_provider_id
  end

  def load_service_providers
    @service_providers = ServiceProvider.select(:id, :name).order(name: :asc)
  end

  def after_inactive_sign_up_path_for(_)
    admin_editors_path
  end

  def pundit_user
    current_editor
  end
end
