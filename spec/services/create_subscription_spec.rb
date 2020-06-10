require 'rails_helper'

RSpec.describe CreateSubscription do
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

  describe '#call' do
    it 'creates a subscription with a user' do
      clean_params = Search.new({}) # Does not run; cleans params
      form = SubscriptionForm.new({
        term: clean_params.term,
        filter: clean_params.filter
      })

      CreateSubscription.new.call(form, @user)
      subscription = Subscription.last

      expect(subscription.user                 ).to eq @user
      expect(subscription.title                ).to eq ''
      expect(subscription.search_term          ).to eq ''
      expect(subscription.countries.map(&:slug)).to eq []
      expect(subscription.sectors.map(&:slug)  ).to eq []
      expect(subscription.types.map(&:slug)    ).to eq []
      expect(subscription.values.map(&:slug)   ).to eq []
    end

    it 'creates a subscription with a search term' do
      clean_params = Search.new({ s: 'lycos' }) # Does not run; cleans params
      form = SubscriptionForm.new({
        term: clean_params.term,
        filter: clean_params.filter
      })

      CreateSubscription.new.call(form, @user)
      subscription = Subscription.last

      expect(subscription.user       ).to eq @user
      expect(subscription.title      ).to eq 'lycos'
      expect(subscription.search_term).to eq 'lycos'
      expect(subscription.countries.map(&:slug)).to eq []
      expect(subscription.sectors.map(&:slug)  ).to eq []
      expect(subscription.types.map(&:slug)    ).to eq []
      expect(subscription.values.map(&:slug)   ).to eq []
    end

    it 'only creates one a subscription' do
      clean_params = Search.new({ s: 'lycos' }) # Does not run; cleans params
      form = SubscriptionForm.new({
        term: clean_params.term,
        filter: clean_params.filter
      })

      expect(@user.subscriptions.count).to eq 0
      CreateSubscription.new.call(form, @user)
      expect(@user.subscriptions.count).to eq 1
      CreateSubscription.new.call(form, @user)
      expect(@user.subscriptions.count).to eq 1
    end

    it 'creates a subscription with two cpv codes' do
      clean_params = Search.new({ cpvs: ['1', '2'] }) # Does not run; cleans params
      form = SubscriptionForm.new({
        term: clean_params.term,
        filter: clean_params.filter,
        cpvs: clean_params.cpvs
      })

      CreateSubscription.new.call(form, @user)
      subscription = Subscription.last

      expect(subscription.user       ).to eq @user
      expect(subscription.title      ).to eq ''
      expect(subscription.search_term).to eq ''
      expect(subscription.countries.map(&:slug)).to eq []
      expect(subscription.sectors.map(&:slug)  ).to eq []
      expect(subscription.types.map(&:slug)    ).to eq []
      expect(subscription.values.map(&:slug)   ).to eq []
      expect(subscription.cpvs.map(&:industry_id)   ).to eq ['1', '2']
    end

    it 'creates a subscription with a list of countries' do
      clean_params = Search.new({ countries: ['wales', 'scotland'] }) # Does not run; cleans params
      form = SubscriptionForm.new({
        term: clean_params.term,
        filter: clean_params.filter
      })

      CreateSubscription.new.call(form, @user)
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

      CreateSubscription.new.call(form, @user)
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

      CreateSubscription.new.call(form, @user)
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

      CreateSubscription.new.call(form, @user)
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