class OpportunityMailerPreview < ActionMailer::Preview
  def send_opportunity
    subscription = Subscription.first_or_create(email: 'blah@blah.com')
    subscription_id = subscription.id
    @user = subscription.user

    @opportunities = [Opportunity.first, Opportunity.find_by_sql('select * from opportunities where source=1').first, Opportunity.last]
    OpportunityMailer.send_opportunity(
      @user,
      {count: 1, subscriptions: {subscription_id: {title: subscription.title, target_url: '/opportunities?s=test', count: 1, opportunity: @opportunities.first}}}
    )
  end
end
