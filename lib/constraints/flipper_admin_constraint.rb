class FlipperAdminConstraint
  def matches?(request)
    current_user = request.env['warden'].user
    return false unless current_user

    whitelisted_emails = Figaro.env.flipper_whitelist!.split(',').map(&:strip)
    whitelisted_emails.include? current_user.email
  end
end
