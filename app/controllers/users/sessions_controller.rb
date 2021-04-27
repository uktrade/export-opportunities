class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # def after_sign_in_path_for(_resource)
  #   super
  # end
  #
  def after_sign_out_path_for(_resource)
    sso_logout_url = "#{Figaro.env.sso_endpoint_base_uri}#{Figaro.env.SSO_ENDPOINT_SSO_APPEND}/accounts/logout/"
    if Figaro.env.bypass_sso?
      root_url
    elsif Figaro.env.magna_header_enabled?
      magna_sso_session_cookie = Figaro.env.magna_sso_session_cookie
      cookie = "session_key=#{cookies[magna_sso_session_cookie]}"
      Faraday.post sso_logout_url do |req|
        req.headers['Cookie'] = cookie
      end
      cookies.delete magna_sso_session_cookie
      root_url
    else
      "#{sso_logout_url}?next=#{root_url}"
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
