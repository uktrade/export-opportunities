require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'Viewing alerts from email digest', elasticsearch: true do
  context 'when already signed in' do
    before(:each) do
      @user = create(:user, email: 'test@example.com')
      @opportunity1 = create(:opportunity, :published, title: 'fog', description: 'foggy day', teaser: 'fog fog more fog')

      login_as @user, scope: :user
    end

    scenario 'view all opportunities from digest' do
      create(:subscription, user_id: @user.id, search_term: '')
      opportunity2 = create(:opportunity, :published)
      opportunity3 = create(:opportunity, :published)

      sleep 2
      visit "/email_notifications/#{EncryptedParams.encrypt(@user.id)}"

      expect(page.body).to include(@opportunity1.title)
      expect(page.body).to include(opportunity2.title)
      expect(page.body).to include(opportunity3.title)
    end

    scenario 'view opportunities from a single subscription from digest email' do
      create(:subscription, user_id: @user.id, search_term: 'sun')
      create(:opportunity, :published, title: 'seaaa')
      create(:opportunity, :published, title: 'sun')
      create(:opportunity, :published, title: 'seashell')

      sleep 2
      visit "/email_notifications/#{EncryptedParams.encrypt(@user.id)}"

      expect(page.body).to include('sun')
      expect(page.body).to_not include('seaaa')
      expect(page.body).to_not include('seashell')
    end

    scenario 'view opportunities from multiple subscriptions from digest email' do
      create(:subscription, user_id: @user.id, search_term: 'sun')
      create(:subscription, user_id: @user.id, search_term: 'shell')
      create(:opportunity, :published, title: 'shell')
      create(:opportunity, :published, title: 'sun')
      create(:opportunity, :published, title: 'rain')

      sleep 2
      visit "/email_notifications/#{EncryptedParams.encrypt(@user.id)}"
      expect(page.body).to include('sun')
      expect(page.body).to include('shell')
      expect(page.body).to_not include('rain')
    end
  end
end
