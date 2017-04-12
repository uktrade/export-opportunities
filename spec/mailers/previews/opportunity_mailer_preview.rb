class OpportunityMailerPreview < ActionMailer::Preview
  def send_opportunity
    subscription = Subscription.first_or_create(email: 'blah@blah.com')
    OpportunityMailer.send_opportunity(
      Opportunity.last,
      subscription
    )
  end
end
