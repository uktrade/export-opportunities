require 'rails_helper'

RSpec.describe CreateSubscription do
  before do
    @user = create(:user)
    @subscription = class_double('Subscription')
    allow(@subscription).to receive(:create!)
    stub_const('Subscription', @subscription)
  end

  describe '#call' do
    it 'creates a subscription with a user' do
      form = fake_form

      expect(@subscription).to receive(:create!)
        .with(a_hash_including(user: @user))

      CreateSubscription.new.call(form, @user)
    end

    it 'creates a subscription with a search term' do
      form = fake_form(search_term: 'lycos')

      expect(@subscription).to receive(:create!)
        .with(a_hash_including(search_term: 'lycos'))

      CreateSubscription.new.call(form, @user)
    end

    it 'creates a subscription with a list of countries' do
      wales = instance_double('Country')
      scotland = instance_double('Country')
      form = fake_form(countries: [wales, scotland])

      expect(@subscription).to receive(:create!)
        .with(a_hash_including(countries: [wales, scotland]))

      CreateSubscription.new.call(form, @user)
    end

    it 'creates a subscription with a list of sectors' do
      circus_equipment = instance_double('Sector')
      playground_apparatus = instance_double('Sector')

      form = fake_form(sectors: [circus_equipment, playground_apparatus])

      expect(@subscription).to receive(:create!)
        .with(a_hash_including(sectors: [circus_equipment, playground_apparatus]))

      CreateSubscription.new.call(form, @user)
    end

    it 'creates a subscription with a list of types' do
      public_sector = instance_double('Type')
      private_sector = instance_double('Type')
      form = fake_form(types: [public_sector, private_sector])

      expect(@subscription).to receive(:create!)
        .with(a_hash_including(types: [public_sector, private_sector]))

      CreateSubscription.new.call(form, @user)
    end

    it 'creates a subscription with a list of values' do
      high = instance_double('Value')
      low = instance_double('Value')
      form = fake_form(values: [high, low])

      expect(@subscription).to receive(:create!)
        .with(a_hash_including(values: [high, low]))

      CreateSubscription.new.call(form, @user)
    end

    def fake_form(search_term: nil, countries: [], sectors: [], types: [], values: [])
      instance_double(
        'SubscriptionForm',
        search_term: search_term,
        countries: countries,
        sectors: sectors,
        types: types,
        values: values
      )
    end
  end
end
