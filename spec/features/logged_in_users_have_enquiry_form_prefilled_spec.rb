require 'rails_helper'

RSpec.feature 'Prepopulate the enquiry form for logged-in Users with past applications', js: true do
  scenario 'User with at least 1 past application should have the enquiry form pre-populated' do
    user = create(:user, email: 'roger@example.com')
    create(:enquiry, user: user)
    create(:sector, name: 'Agriculture')
    create :enquiry,
      opportunity: create(:opportunity, title: 'CHINA: Widgets Wanted', slug: 'china-widgets-wanted', status: :publish),
      user: user,
      first_name: 'Roger',
      last_name:  'Rogerson',
      company_telephone: '0818118181',
      company_name: 'Agricultural Widgets Ltd',
      company_house_number: '12345',
      company_address: 'Agricultural Widget Towers, London',
      company_postcode: 'NW1 8TQ',
      company_url: 'http://agriwidget.co.uk',
      company_explanation: 'Our widgets are ready for export',
      company_sector: 'Agriculture',
      existing_exporter: 'Yes, in the last year',
      data_protection: true

    create(:opportunity, title: 'SOUTH AFRICA: Widgets Wanted', slug: 'south-africa-widgets-wanted', status: :publish)

    login_as(user, scope: :user)

    visit '/enquiries/south-africa-widgets-wanted'

    within '#new_enquiry' do
      expect(page).to have_field('enquiry[first_name]', with: 'Roger')
      expect(page).to have_field('enquiry[last_name]', with: 'Rogerson')
      expect(page).to have_field('enquiry[company_telephone]', with: '0818118181')
      expect(page).to have_field('enquiry[company_name]', with: 'Agricultural Widgets Ltd')

      aggregate_failures do
        expect(page).to have_no_content("I don't have a Companies House Number")
        expect(page).to have_no_selector('#no-companies-house-number')
      end

      expect(page).to have_field('enquiry[company_house_number]', with: '12345')
      expect(page).to have_field('enquiry[company_address]', with: 'Agricultural Widget Towers, London')
      expect(page).to have_field('enquiry[company_postcode]', with: 'NW1 8TQ')
      expect(page).to have_field('enquiry[company_url]', with: 'http://agriwidget.co.uk')
      expect(page).to have_field('enquiry[company_explanation]', with: '')
      expect(page).to have_field('enquiry[company_sector]', with: 'Agriculture')
      expect(page).to have_select('enquiry[existing_exporter]', selected: 'Yes, in the last year')
    end

    # capybara cant find the "I agree my details to be used by DIT and partners" checkbox inside the form, but it is there..
    data_protection_checkbox = find(:css, '#enquiry_data_protection', visible: false)
    expect(data_protection_checkbox.checked?).to eq true
  end
end
