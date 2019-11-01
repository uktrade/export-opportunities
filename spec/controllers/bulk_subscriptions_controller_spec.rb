require 'rails_helper'

RSpec.describe BulkSubscriptionsController, sso: true do
  describe '#create' do
    before(:each) do
      user = create(:user, email: 'test@example.com')

      sign_in user
    end

    it 'creates a bulk subscription' do
      expect { post :create }.to change { Subscription.count }.by(1)

      subscription = Subscription.last

      expect(subscription.email).to eql 'test@example.com'
      expect(subscription.confirmed_at).to be_present
      expect(subscription.search_term).to be_nil
      expect(subscription.countries).to be_empty
      expect(subscription.sectors).to be_empty
      expect(subscription.types).to be_empty
      expect(subscription.values).to be_empty
    end
  end
end
