require 'rails_helper'

RSpec.describe Subscription do
  it { is_expected.to have_and_belong_to_many(:countries) }
  it { is_expected.to have_and_belong_to_many(:sectors) }
  it { is_expected.to have_and_belong_to_many(:types) }
  it { is_expected.to have_and_belong_to_many(:values) }
  it { is_expected.to have_many(:notifications) }

  describe '.confirmed' do
    it 'includes only subscriptions that are confirmed' do
      confirmed_subscription = create(:subscription, confirmed_at: 1.hour.ago)
      unconfirmed_subscription = create(:subscription, confirmed_at: nil)

      subscriptions = Subscription.confirmed

      expect(subscriptions).to include(confirmed_subscription)
      expect(subscriptions).to_not include(unconfirmed_subscription)
    end
  end

  describe '.unconfirmed' do
    it 'includes only subscriptions that are NOT confirmed' do
      confirmed_subscription = create(:subscription, confirmed_at: 1.hour.ago)
      unconfirmed_subscription = create(:subscription, confirmed_at: nil)

      subscriptions = Subscription.unconfirmed

      expect(subscriptions).to_not include(confirmed_subscription)
      expect(subscriptions).to include(unconfirmed_subscription)
    end
  end

  describe '.active' do
    it 'excludes subscriptions that have been unsubscribed' do
      unsubscribed_subscription = create(:subscription, :unsubscribed)
      active_subscription = create(:subscription)

      subscriptions = Subscription.active

      expect(subscriptions).to_not include(unsubscribed_subscription)
      expect(subscriptions).to include(active_subscription)
    end
  end

  describe '.unsubscribed' do
    it 'includes subscriptions that have been unsubscribed' do
      unsubscribed_subscription = create(:subscription, :unsubscribed)
      active_subscription = create(:subscription)

      subscriptions = Subscription.unsubscribed

      expect(subscriptions).to include(unsubscribed_subscription)
      expect(subscriptions).to_not include(active_subscription)
    end
  end

  describe '.valid?' do
    before(:each) do
      @user = create(:user)
    end

    it 'true when a search term is provided' do
      subscription = Subscription.new search_term: 'Thermal Insulators', user: @user
      expect(subscription).to be_valid
    end

    it 'true when a country is provided' do
      subscription = Subscription.new countries: [create(:country)], user: @user
      expect(subscription).to be_valid
    end

    it 'true when a sector is provided' do
      subscription = Subscription.new sectors: [create(:sector)], user: @user
      expect(subscription).to be_valid
    end

    it 'true when a value is provided' do
      subscription = Subscription.new values: [create(:value)], user: @user
      expect(subscription).to be_valid
    end

    it 'true when a type is provided' do
      subscription = Subscription.new types: [create(:type)], user: @user
      expect(subscription).to be_valid
    end

    it 'true when a search term and filter provided' do
      subscription = Subscription.new(
        user: @user,
        search_term: 'Thermal Insulators',
        countries: [create(:country)],
        sectors: [create(:sector)],
        values: [create(:value)],
        types: [create(:type)]
      )
      expect(subscription).to be_valid
    end

    it 'true when a search term and multiple filter provided' do
      subscription = Subscription.new(
        user: @user,
        search_term: 'Thermal Insulators',
        countries: create_list(:country, 3),
        sectors: create_list(:sector, 3),
        values: create_list(:value, 3),
        types: create_list(:type, 3)
      )
      expect(subscription).to be_valid
    end

    it 'true when just the user is provided' do
      user = create(:user)
      subscription = Subscription.new(user: user)
      expect(subscription).to be_valid
    end

    it 'false when no values are provided' do
      subscription = Subscription.new
      expect(subscription).not_to be_valid
    end
  end

  # TODO: FIX BELOW
  describe 'create' do
    before do
      @user = create(:user)
      create(:country, name: "Wales", slug: 'wales')
      create(:country, name: "Scotland", slug: 'scotland')
      create(:sector, name: "Circus", slug: 'circus')
      create(:sector, name: "Playground Apparatus", slug: 'playground-apparatus')
      create(:value, name: "High", slug: 'high')
      create(:value, name: "Low", slug: 'low')
      create(:type, name: "Public Sector", slug: 'public-sector')
      create(:type, name: "Private Sector", slug: 'private-sector')
    end

    describe '#data', focus: true do
      it 'creates a subscription with a user' do
        Subscription.create(
          user: @user
        )
        subscription = Subscription.last

        expect(subscription.user                 ).to eq @user
        expect(subscription.title                ).to eq nil
        expect(subscription.search_term          ).to eq nil
        expect(subscription.countries.map(&:slug)).to eq []
        expect(subscription.sectors.map(&:slug)  ).to eq []
        expect(subscription.types.map(&:slug)    ).to eq []
        expect(subscription.values.map(&:slug)   ).to eq []
      end

      it 'creates a subscription with a search term' do
        # clean_params = Search.new({ s: 'lycos' }) # Does not run; cleans params
        # form = SubscriptionForm.new({
        #   term: clean_params.term,
        #   filter: clean_params.filter
        # })

        Subscription.create!({
          search_term: 'lycos',
          title: 'lycos',
          user: @user
        })

        subscription = Subscription.last

        expect(subscription.user       ).to eq @user
        expect(subscription.title      ).to eq 'lycos'
        expect(subscription.search_term).to eq 'lycos'
        expect(subscription.countries.map(&:slug)).to eq []
        expect(subscription.sectors.map(&:slug)  ).to eq []
        expect(subscription.types.map(&:slug)    ).to eq []
        expect(subscription.values.map(&:slug)   ).to eq []
      end

      it 'creates a subscription with a list of countries' do
        clean_params = Search.new({ countries: ['wales', 'scotland'] }) # Does not run; cleans params
        form = SubscriptionForm.new({
          term: clean_params.term,
          filter: clean_params.filter
        })

        Subcription.create(
          form, @user
        )
        subscription = Subscription.last
        
        expect(subscription.user       ).to eq @user
        expect(subscription.title      ).to eq "Scotland or Wales"
        expect(subscription.search_term).to eq ''
        expect(subscription.countries.map(&:slug)).to eq ['wales', 'scotland']
        expect(subscription.sectors.map(&:slug)  ).to eq []
        expect(subscription.types.map(&:slug)    ).to eq []
        expect(subscription.values.map(&:slug)   ).to eq []
      end

      it 'creates a subscription with a list of sectors' do
        clean_params = Search.new({ sectors: ['circus', 'playground-apparatus'] }) # Does not run; cleans params
        form = SubscriptionForm.new({
          term: clean_params.term,
          filter: clean_params.filter
        })

        Subcription.create(
          form, @user
        )
        subscription = Subscription.last

        expect(subscription.user       ).to eq @user
        expect(subscription.title      ).to eq ''
        expect(subscription.search_term).to eq ''
        expect(subscription.countries.map(&:slug)).to eq []
        expect(subscription.sectors.map(&:slug)  ).to eq ['circus', 'playground-apparatus']
        expect(subscription.types.map(&:slug)    ).to eq []
        expect(subscription.values.map(&:slug)   ).to eq []
      end

      it 'creates a subscription with a list of types' do
        clean_params = Search.new({ types: ['public-sector', 'private-sector'] }) # Does not run; cleans params
        form = SubscriptionForm.new({
          term: clean_params.term,
          filter: clean_params.filter
        })

        Subcription.create(
          form, @user
        )
        subscription = Subscription.last

        expect(subscription.user       ).to eq @user
        expect(subscription.title      ).to eq ''
        expect(subscription.search_term).to eq ''
        expect(subscription.countries.map(&:slug)).to eq []
        expect(subscription.sectors.map(&:slug)  ).to eq []
        expect(subscription.types.map(&:slug)    ).to eq ['public-sector', 'private-sector']
        expect(subscription.values.map(&:slug)   ).to eq []
      end

      it 'creates a subscription with a list of values' do
        clean_params = Search.new({ values: ['high', 'low'] }) # Does not run; cleans params
        form = SubscriptionForm.new({
          term: clean_params.term,
          filter: clean_params.filter
        })

        Subcription.create(
          form, @user
        )
        subscription = Subscription.last

        expect(subscription.user       ).to eq @user
        expect(subscription.title      ).to eq ''
        expect(subscription.search_term).to eq ''
        expect(subscription.countries.map(&:slug)).to eq []
        expect(subscription.sectors.map(&:slug)  ).to eq []
        expect(subscription.types.map(&:slug)    ).to eq []
        expect(subscription.values.map(&:slug)   ).to eq ['high', 'low']
      end
    end
  end

end
