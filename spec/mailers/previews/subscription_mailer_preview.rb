class SubscriptionMailerPreview < ActionMailer::Preview
  def confirmation_instructions
    SubscriptionMailer.confirmation_instructions(Subscription.last, 'dummy_token')
  end
end
