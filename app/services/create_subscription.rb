class CreateSubscription
  #
  # Creates a subscription
  # Inputs: SubscriptionForm and a User
  #
  def call(form, user)
    form_output = form.data
    subscription = Subscription.new(
      user: user,
      title: form_output[:title],
      search_term: form.search_term,
      countries: form.countries,
      sectors: form.sectors,
      types: form.types,
      values: form.values,
      confirmed_at: Time.zone.now
    )
    if (existing = Subscription.find_by(
      user: subscription.user,
      title: subscription.title,
      search_term: subscription.search_term)).present? &&
      existing.countries.map(&:id) == form.countries.map(&:id) &&
      existing.sectors.map(&:id) == form.sectors.map(&:id) &&
      existing.types.map(&:id) == form.types.map(&:id) &&
      existing.values.map(&:id) == form.values.map(&:id)
      return existing
    end
    subscription.save
    form.cpvs.each do |cpv|
      subscription.cpvs.create(industry_id: cpv)
    end
    subscription
  end
end
