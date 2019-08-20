module CookieHelper
  # is the user is signed in via the cookie check?
  def user_signed_in_cookie?
    return false if request.nil? || cookies[:sso_display_logged_in].nil?

    cookies[:sso_display_logged_in] == 'true'
  end
end