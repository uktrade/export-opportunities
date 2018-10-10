require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'Subscribing to alerts', elasticsearch: true do
  context 'when already signed in' do
    before(:each) do
      @user = create(:user, email: 'test@example.com')
      login_as @user, scope: :user
    end

    scenario 'given a search keyword, should be confirmed' do
      create(:opportunity, title: 'Food', status: :publish)

      visit opportunities_path
      within '.search' do
        fill_in :s, with: 'food'
        page.find('.submit').click
      end

      expect(page.body).to include 'Subscribe to email alerts'
      expect(page.body).to include 'for food'

      click_on 'Subscribe to email alerts for food'

      subscription = @user.subscriptions.first
      expect(subscription.search_term).to eq('food')

      expect(page).to have_content 'Your daily email alert has been added'
      expect(page).to have_content 'You currently receive email alerts for the following search terms: food'

      subscription.reload
      expect(subscription).to be_confirmed
    end

    scenario 'when a filter is provided, should be confirmed' do
      country = create(:country, name: 'Italy')
      create(:opportunity, status: :publish, countries: [country])
      create(:type, name: 'Public Sector')
      create(:value, name: 'More than £100k')
      create(:supplier_preference)

      sleep 1

      visit opportunities_path


      find('#countries_0').set(true)
      click_on 'Update results'

      expect(page.body).to include 'Subscribe to email alerts in Italy'

      click_button 'Subscribe to email alerts in Italy'

      subscription = @user.subscriptions.first
      expect(subscription.search_term).to eq ''
      expect(subscription.countries.count).to eq 1
      expect(subscription.countries.first.name).to eq 'Italy'

      expect(page.body).to have_content 'Your daily email alert has been added'

      # subscription includes countries
      expect(page.body).to have_content 'Italy'

      subscription.reload
      expect(subscription).to be_confirmed
    end

    scenario 'can subscribe when multiple filters and search terms are provided, should be confirmed', js: true do
      skip('TODO: fix')
      country = create(:country, name: 'Italy')
      sector = create(:sector, name: 'Toys')
      type = create(:type, name: 'Magical')
      value = create(:value, name: 'Expensive')
      sentence = 'A company in Italy would like to buy transformers'

      create(
        :opportunity,
        title: sentence,
        status: :publish,
        countries: [country],
        sectors: [sector],
        types: [type],
        values: [value]
      )

      visit opportunities_path
      expect(page).not_to have_content 'Subscribe to email alerts for transformers, Italy, Toys, Magical, Expensive'

      fill_in :s, with: 'transformers'
      select 'Toys', from: 'sector', visible: false
      select 'Italy', from: 'countries[]', visible: false
      select 'Magical', from: 'types', visible: false
      select 'Expensive', from: 'values', visible: false

      page.find('.filters__searchbutton').click

      expect(page).to have_content 'Subscribe to email alerts for transformers, Italy, Toys, Magical, Expensive'

      click_button 'Subscribe'
      wait_for_ajax

      expect(page).to have_content 'Your email alert has been created'
      expect(page).to have_content 'Search term:'
      expect(page).to have_content 'transformers'
      expect(page).to have_content 'Italy'
      expect(page).to have_content 'Toys'
      expect(page).to have_content 'Magical'
      expect(page).to have_content 'Expensive'
    end

    scenario 'cannot subscribe when no search keywords or filters are provided' do
      visit opportunities_path
      expect(page).to have_no_content 'Subscribe to Email Alerts'
    end

    scenario 'can not subscribe to all opportunities' do
      create(:opportunity, :published)
      visit opportunities_path

      expect(page.body).to_not include 'Subscribe to email alerts'
    end
  end

  context 'when not signed in' do
    scenario 'can subscribe to email alerts' do
      skip 'TODO: fix pending_subscriptions_controller#update method, doesnt pass content var but page presenter view requires it'
      mock_sso_with(email: 'test@example.com')

      create(:opportunity, title: 'Food')

      visit opportunities_path
      fill_in :s, with: 'food'
      page.find('.submit').click

      expect(page.body).to include 'Subscribe to email alerts for food'

      click_button 'Subscribe to email alerts for food'

      expect(page).to have_content 'Your email alert has been created'
      expect(page).to have_content 'Search term: food'
    end
  end
end
