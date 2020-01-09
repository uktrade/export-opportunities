class Admin::RegistrationsController < Devise::RegistrationsController
  include Pundit
  after_action :verify_authorized
  before_action :configure_permitted_parameters
  before_action :load_service_providers
  before_action :set_no_cache_headers

  skip_before_action :require_no_authentication, raise: false

  rescue_from Pundit::NotAuthorizedError, with: :not_found

  layout 'admin'
  layout 'admin_transformed', only: %i[new create]

  # GET /resource/sign_up
  def new
    @editor_content = get_content('admin/editors.yml')
    @editor_roles = editor_roles
    super do |resource|
      authorize resource
    end
  end

  # POST /resource
  def create
    @editor_content = get_content('admin/editors.yml')
    @editor_roles = editor_roles
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

  private

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
      devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
      devise_parameter_sanitizer.permit(:sign_up, keys: [:service_provider_id])
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

    def editor_roles
      roles = []
      Editor.roles.each do |key, value|
        roles.push Role.new(key, value)
      end
      roles
    end

    class Role
      attr_reader :name, :value, :id

      def initialize(name, value)
        @name = name.capitalize
        @id = name.downcase
        @value = value
      end
    end
end
