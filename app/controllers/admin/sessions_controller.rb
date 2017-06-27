class Admin::SessionsController < Devise::SessionsController
  def after_sign_in_path_for(_resource)
    super
    # admin_opportunities_path
  end

  def after_sign_out_path_for(_resource)
    new_editor_session_path
  end
end
