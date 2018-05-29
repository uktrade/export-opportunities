require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe OpportunityMailer, type: :mailer do
  describe '.send_opportunity' do
    it 'formats the subject line correctly with multiple opportunities' do
      #user = create(:user, {username: 'fredusername', name: 'fredname', email: 'test@example.com'})
      user = create(:user, email: 'test@example.com')
      subscription = create(:subscription, user: user)
      opportunities = [create(:opportunity), create(:opportunity)]

      OpportunityMailer.send_opportunity(user, opportunities).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last
      expect(last_delivery.subject).to eql '2 matching opportunities'
    end

    it 'formats the subject line correctly for a single opportunity' do
      #user = create(:user, {username: 'fredusername', name: 'fredname', email: 'test@example.com'})
      user = create(:user, email: 'test@example.com')
      subscription = create(:subscription, user: user)
      opportunities = [create(:opportunity)]

      OpportunityMailer.send_opportunity(user, opportunities).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last
      expect(last_delivery.subject).to eql '1 matching opportunity'
    end

    it 'sends the opportunity to subscriptions' do
      skip('TODO: refactor with digest email')
      user = create(:user, email: 'test@example.com')
      subscription = create(:subscription, user: user)
      opportunity = create(:opportunity)

      OpportunityMailer.send_opportunity(opportunity, subscription).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.subject).to eql 'New opportunity from Export opportunities: ' + opportunity.title
      expect(last_delivery.to).to include(user.email)
      expect(last_delivery.to_s).to include(opportunity.title)
      expect(last_delivery.to_s).to include(opportunity.teaser)
    end

    it 'includes a link to manage your subscriptions if you have a SSO user account' do
      skip('TODO: refactor with digest email')
      user = create(:user, email: 'test@example.com')
      opportunity = create(:opportunity)
      subscription = create(:subscription, user: user)

      OpportunityMailer.send_opportunity(opportunity, subscription).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.text_part.to_s).to include('Manage your alerts')
      expect(last_delivery.html_part.to_s).to include('Manage your alerts')
    end

    it 'does not include a link to manage your subscriptions if you only have a stub user account' do
      skip('TODO: refactor with digest email')
      user = create(:user, :stub, email: 'someone@new.com')
      opportunity = create(:opportunity)
      subscription = create(:subscription, user: user)

      OpportunityMailer.send_opportunity(opportunity, subscription).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.text_part.to_s).not_to include('Manage your alerts')
      expect(last_delivery.html_part.to_s).not_to include('Manage your alerts')
    end
  end
end
