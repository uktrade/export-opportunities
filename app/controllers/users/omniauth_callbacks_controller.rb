class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :developer

  # This method name matches the omniauth provider name
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  def exporting_is_great
    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @user
    set_flash_message(:notice, :success) if is_navigational_format?
  end

  def developer
    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @user
    set_flash_message(:notice, :success) if is_navigational_format?
  end

  def magna
    sso_id = cookies[sso_session_cookie]
    if sso_user = DirectoryApiClient.user_data(sso_id)
      request.env['omniauth.auth']['info'] = sso_user
      request.env['omniauth.auth']['uid'] = sso_user['id']
      @user = User.from_omniauth(request.env['omniauth.auth'])
      sign_in_and_redirect @user
      set_flash_message(:notice, :success) if is_navigational_format?
    else
      failure_message = 'Authentication error'
      redirect_to root_path
      set_flash_message(:alert, :failure, reason: failure_message)
    end
  end

  def failure
    @error = request.env['omniauth.error.type']
  end
end
