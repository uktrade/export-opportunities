class SubscriptionMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  layout 'eig-email'

  def confirmation_instructions(record, token, opts = {})
    description = SubscriptionPresenter.new(record).description
    opts[:subject] = "Please confirm your subscription for notifications about #{description}"
    @button_target = subscription_confirmation_url(confirmation_token: token)
    super(record, token, opts)
  end
end
