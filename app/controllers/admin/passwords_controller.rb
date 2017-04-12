class Admin::PasswordsController < Devise::PasswordsController
  def after_resetting_password_path_for(_resource)
    admin_opportunities_path
  end
end
