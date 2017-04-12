class SubscriptionFinder
  def call(opportunity)
    @country_ids = opportunity.country_ids
    @sector_ids = opportunity.sector_ids
    @type_ids = opportunity.type_ids
    @value_ids = opportunity.value_ids

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

  private def matching_subscriptions
    @matching_subscriptions ||= Subscription.where(id: matching_subscription_ids).to_a
  end

  private def matching_subscription_ids
    matching_filters.ids.uniq
  end

  private def matching_filters
    Subscription
      .confirmed
      .active
      .joins('LEFT OUTER JOIN countries_subscriptions ON subscriptions.id = countries_subscriptions.subscription_id')
      .joins('LEFT OUTER JOIN sectors_subscriptions ON subscriptions.id = sectors_subscriptions.subscription_id')
      .joins('LEFT OUTER JOIN subscriptions_types ON subscriptions.id = subscriptions_types.subscription_id')
      .joins('LEFT OUTER JOIN subscriptions_values ON subscriptions.id = subscriptions_values.subscription_id')
      .where('countries_subscriptions.country_id IS NULL OR countries_subscriptions.country_id IN (?)', @country_ids)
      .where('sectors_subscriptions.sector_id IS NULL OR sectors_subscriptions.sector_id IN (?)', @sector_ids)
      .where('subscriptions_types.type_id IS NULL OR subscriptions_types.type_id IN (?)', @type_ids)
      .where('subscriptions_values.value_id IS NULL OR subscriptions_values.value_id IN (?)', @value_ids)
  end
end
