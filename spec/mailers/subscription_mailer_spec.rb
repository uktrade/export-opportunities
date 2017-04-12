require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe SubscriptionMailer do
  describe '.confirmation_instructions' do
    it 'generates an appropriate subject line' do
      user = create(:user, email: 'test@example.com')
      subscription = create(:subscription, search_term: nil, user: user)

      SubscriptionMailer.confirmation_instructions(subscription, 'dummy_token').deliver_now

      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql 'Please confirm your subscription for notifications about all opportunities'
    end
  end
end
