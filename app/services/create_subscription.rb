class CreateSubscription
  #
  # Creates a subscription
  # Inputs: SubscriptionForm and a User
  #
  def call(form, user)
    form_output = form.data
    Subscription.create!(
      user: user,
      title: form_output[:title],
      search_term: form.search_term,
      cpv_industry_ids: form.cpvs,
      countries: form.countries,
      sectors: form.sectors,
      types: form.types,
      values: form.values,
      confirmed_at: Time.zone.now
    )
  end
end