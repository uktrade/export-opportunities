class OpportunityMailerPreview < ActionMailer::Preview
  def send_opportunity
    subscription = Subscription.first_or_create(email: 'blah@blah.com')
    @user = subscription.user

    @opportunities = [Opportunity.first, Opportunity.find_by_sql('select * from opportunities where source=1').first, Opportunity.last]
    OpportunityMailer.send_opportunity(
      @user,
      @opportunities
    )
  end
end
