class OpportunityMailerPreview < ActionMailer::Preview
  def send_opportunity
    @subscription = Subscription.first_or_create(search_term: 'cars')
    country = Country.first
    @subscription.countries.push country unless @subscription.countries.size > 0
    url_from_subscription = SendOpportunitiesDigest.new.url_from_subscription(@subscription)
    @subscription_id = @subscription.id

    @another_subscription = Subscription.new(search_term: '')
    another_url_from_subscription = SendOpportunitiesDigest.new.url_from_subscription(@another_subscription)
    @another_subscription_id = @another_subscription.id
    @user = @subscription.user


    @opportunities = [Opportunity.first, Opportunity.find_by_sql('select * from opportunities where source=1').first, Opportunity.last]
    subscription_struct = {}
    subscription_struct[@subscription_id] = {subscription: @subscription, target_url: url_from_subscription, count: 1, opportunity: @opportunities.first}

    subscription_struct[@another_subscription_id] = {subscription: @another_subscription, target_url: another_url_from_subscription, count: 1, opportunity: @opportunities.last}
byebug
    OpportunityMailer.send_opportunity(
      @user,
      {count: 1, subscriptions: subscription_struct}
    )
  end
end
