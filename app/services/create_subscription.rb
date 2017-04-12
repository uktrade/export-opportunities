class CreateSubscription
  def call(form, user)
    Subscription.create!(
      user: user,
      search_term: form.search_term,
      countries: form.countries,
      sectors: form.sectors,
      types: form.types,
      values: form.values,
      confirmed_at: Time.zone.now
    )
  end
end
