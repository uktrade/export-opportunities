Warden::Strategies.add(:deactivated) do
  def valid?
    editor_logging_in?
  end

  def authenticate!
    editor = Editor.find_by(email: email)
    return unless editor&.deactivated_at?

    fail!('This account has been deactivated')
  end

  private def editor_logging_in?
    params['commit'].eql?('Log in') && email
  end

  private def email
    params['editor']['email']
  end
end
