class CreateSubscription
  #
  # Creates a subscription
  # Inputs: SubscriptionForm.output and a User
  #
  def call(form_output, user)
    Subscription.create!(
      user: user,
      title: form_output[:title],
      search_term: form_output[:term],
      cpvs: form_output[:cpvs],
      countries: form_output[:countries],
      sectors: form_output[:sectors],
      types: form_output[:types],
      values: form_output[:values],
      confirmed_at: Time.zone.now
    )
  end
end
