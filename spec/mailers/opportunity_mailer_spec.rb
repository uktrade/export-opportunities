require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe OpportunityMailer, type: :mailer do

  describe '.send_opportunity' do
    it 'formats the subject line correctly with multiple opportunities' do
      user = create(:user, email: 'test@example.com')
      subscription = create(:subscription, user: user)

      OpportunityMailer.send_opportunity(user, {count: 2, subscriptions: {}}).deliver_now!

      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql '2 matching opportunities'
    end

    it 'formats the subject line correctly for a single opportunity' do
      user = create(:user, email: 'test@example.com')
      subscription = create(:subscription, user: user)

      OpportunityMailer.send_opportunity(user, {count: 1, subscriptions: {}}).deliver_now!

      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql '1 matching opportunity'
    end

  end
end
