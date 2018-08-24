class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # def after_sign_in_path_for(_resource)
  #   super
  # end
  #
  def after_sign_out_path_for(_resource)
    if ENV.key?('bypass_sso')
      opportunities_url
    else
      "#{ENV['SSO_ENDPOINT_BASE_URI']}/accounts/logout?next=#{opportunities_url}"
    end
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  def destroy
    super do
      flash.clear
    end
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
