require 'elasticsearch'

class SubscriptionFinder
  def call(opportunity)
    @country_ids = opportunity.country_ids
    @sector_ids = opportunity.sector_ids
    @type_ids = opportunity.type_ids
    @value_ids = opportunity.value_ids
    @search_term = opportunity.title

    matching_subscriptions.select do |subscription|
      if subscription.search_term.present?
        Opportunity.where(id: opportunity.id)
          .search(subscription.search_term)
          .present?
      else
        true
      end
    end
  end

  private

    def matching_subscriptions
      query = SubscriptionSearchBuilder.new(
        search_term: '',
        sectors: @sector_ids,
        countries: @country_ids,
        opportunity_types: @type_ids,
        values: @value_ids
      ).call
      Subscription.__elasticsearch__.refresh_index!

# Stuck
# # Doesn't work
# query={:search_query=>{:bool=>{:must=>[{:match_all=>{}}, {:bool=>{:filter=>{:exists=>{:field=>:confirmed_at}}}}, {:bool=>{:must_not=>{:exists=>{:field=>:unsubscribed_at}}}}], :should=>[{:terms=>{:"countries.id"=>[1]}}, {:bool=>{:must_not=>{:exists=>{:field=>"countries.id"}}}}], :minimum_should_match=>1}}}

# # Does work
# query={:search_query=>{:bool=>{:must=>[{:match_all=>{}}, {:bool=>{:must_not=>{:exists=>{:field=>:unsubscribed_at}}}}], :should=>[{:terms=>{:"countries.id"=>[1]}}, {:bool=>{:must_not=>{:exists=>{:field=>"countries.id"}}}}], :minimum_should_match=>1}}}



      # TODO: window size must be <= #of active subscribers
      @matching_subscriptions ||= Subscription.__elasticsearch__.search(
        size: Figaro.env.SUBSCRIPTION_ES_MAX_RESULT_WINDOW_SIZE || 10_000,
        query: query[:search_query]
      ).records.to_a
    end
end
