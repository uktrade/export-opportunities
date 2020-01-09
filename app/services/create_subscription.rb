class CreateSubscription
  #
  # Creates a subscription
  # Inputs: SubscriptionForm and a User
  #
  def call(form, user)
    form_output = form.data
    subscription = Subscription.create!(
      user: user,
      title: form_output[:title],
      search_term: form.search_term,
      countries: form.countries,
      sectors: form.sectors,
      types: form.types,
      values: form.values,
      confirmed_at: Time.zone.now
    )
    form.cpvs.each do |cpv|
      subscription.cpvs.create(industry_id: cpv)
    end
    subscription
  end
end
