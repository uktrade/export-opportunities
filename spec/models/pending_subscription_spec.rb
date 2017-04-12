require 'rails_helper'

describe PendingSubscription do
  it { is_expected.to belong_to(:subscription) }

  describe '#activated?' do
    it 'returns true if a subscription has been created' do
      pending_sub = PendingSubscription.new
      pending_sub.subscription = create(:subscription)
      expect(pending_sub.activated?).to eq true
    end

    it 'returns false if no subscription has been created' do
      pending_sub = PendingSubscription.new
      expect(pending_sub.activated?).to eq false
    end
  end
end
