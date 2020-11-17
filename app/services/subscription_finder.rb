# frozen_string_literal: true

require 'elasticsearch'

# SubscriptionFinder is a service objectt which runs a search for subscriptions
# that match a given opportunity object
class SubscriptionFinder
  ACTIVE_SUBSCRIPTIONS_COUNT = Subscription.active.size.freeze

  def call(opportunity)
    @sector_ids  = opportunity.sector_ids
    @country_ids = opportunity.country_ids
    @type_ids    = opportunity.type_ids
    @value_ids   = opportunity.value_ids

    matching_subscriptions.select do |subscription|
      next unless subscription.search_term.present?

      Opportunity.search(subscription.search_term).present?
    end
  end

  private

  def matching_subscriptions
    query = SubscriptionSearchBuilder.new(
      sectors: @sector_ids, countries: @country_ids, types: @type_ids,
      values: @value_ids
    ).call

    Subscription.__elasticsearch__.refresh_index!

    # TODO: window size must be <= #of active subscribers
    @matching_subscriptions ||= Subscription.__elasticsearch__.search(
      size: Figaro.env.SUBSCRIPTION_ES_MAX_RESULT_WINDOW_SIZE || 10_000,
      query: query[:search_query]
    ).records.to_a
  end
end
