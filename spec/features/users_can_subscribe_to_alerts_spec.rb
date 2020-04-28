# coding: utf-8
require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'Subscribing to alerts', elasticsearch: true, sso: true do
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

      expect(page.body).to include 'Set up email alerts'
      expect(page.body).to include 'for food'

      click_on 'Set up email alerts for food'

      subscription = @user.subscriptions.first
      expect(subscription.search_term).to eq('food')

      expect(page).to have_content 'Your daily email alert has been added'
      expect(page).to have_content 'You currently receive email alerts for the following search terms:'
      expect(page).to have_content 'food'

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

      expect(page.body).to include 'Set up email alerts in Italy'

      click_button 'Set up email alerts in Italy'

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
      expect(page).not_to have_content 'Set up email alerts for transformers, Italy, Toys, Magical, Expensive'

      fill_in :s, with: 'transformers'
      select 'Toys', from: 'sector', visible: false
      select 'Italy', from: 'countries[]', visible: false
      select 'Magical', from: 'types', visible: false
      select 'Expensive', from: 'values', visible: false

      page.find('.filters__searchbutton').click

      expect(page).to have_content 'Set up email alerts for transformers, Italy, Toys, Magical, Expensive'

      click_button 'Set up'
      wait_for_ajax

      expect(page).to have_content 'Your email alert has been created'
      expect(page).to have_content 'Search term:'
      expect(page).to have_content 'transformers'
      expect(page).to have_content 'Italy'
      expect(page).to have_content 'Toys'
      expect(page).to have_content 'Magical'
      expect(page).to have_content 'Expensive'
    end
  end

  context 'when not signed in' do
    scenario 'can unsubscribe to email alerts' do
      ActiveJob::Base.queue_adapter = :test
      
      # Create a subscription
      user = create(:user, email: 'test@example.com')
      opportunity = create(:opportunity, title: 'Food')
      create(:subscription, user: user, search_term: 'Food')
      expect(user.subscriptions.where(unsubscribed_at: nil).count).to eq 1

      # Go to unsubscription link, expect email queued
      expect{
        visit delete_email_notifications_path(unsubscription_token: user.unsubscription_token)
      }.to have_enqueued_job
      expect(page).to have_content "You have been unsubscribed from all email alerts"

      expect(user.subscriptions.where(unsubscribed_at: nil).count).to eq 0
    end
  end
end
