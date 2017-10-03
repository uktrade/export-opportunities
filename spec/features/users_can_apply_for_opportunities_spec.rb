require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'users can apply for opportunities', js: true do
  before :each do
    mock_sso_with(email: 'email@example.com')
  end

  scenario 'application is not possible when the opportunity has expired' do
    expired_opportunity = create(:opportunity, :expired, status: :publish, slug: 'expired-opp')
    visit 'enquiries/expired-opp'

    expect(page).not_to be_an_enquiry_form
    expect(page).to have_content expired_opportunity.title
    expect(page).to have_content t('opportunity.expired')
  end

  context 'when the user already has an account' do
    before do
      create(:opportunity, slug: 'great-opportunity', status: :publish)
      create(:sector)
    end

    scenario 'if they are logged in' do
      mock_sso_with(email: 'enquirer@exporter.com')

      visit 'enquiries/great-opportunity'

      expect(page).not_to have_field 'Email Address'

      fill_in_form
      click_on 'Apply now'

      expect(page).to have_content 'Thank you for your enquiry'
      expect(page).to have_link 'View your enquiries to date'

      visit 'enquiries/great-opportunity'
    end

    scenario 'if they are logged in, apply with company house number', js: true do
      mock_sso_with(email: 'enquirer@exporter.com')
      company_detail = {
        name: 'Boring Export Company',
        number: 123_456_78,
        postcode: 'sw1a',
      }
      allow_any_instance_of(CompanyHouseFinder).to receive(:call).and_return([company_detail])

      visit 'enquiries/great-opportunity'

      expect(page).not_to have_field 'Email Address'

      fill_in_your_details

      fill_in 'enquiry[company_name]', with: 'Boring Export Company'

      click_on 'Search Companies House'

      wait_for_ajax

      click_on 'Boring Export Company'

      fill_in 'Company Address', with: '3 whp'
      fill_in_exporting_experience
      tick_data_protection_checkbox

      click_on 'Apply now'

      expect(page).to have_content 'Thank you for your enquiry'
      expect(page).to have_link 'View your enquiries to date'

      visit 'enquiries/great-opportunity'

      expect(find_field('enquiry_company_house_number').value).to eq '12345678'
    end

    scenario 'if they are not logged in' do
      mock_sso_with(email: 'enquirer@exporter.com')

      visit 'enquiries/great-opportunity'

      expect(page).to be_an_enquiry_form
    end

    scenario 'when a user exists on our end' do
      create(:user, email: 'apple@fruit.com', uid: '123456', provider: 'exporting_is_great')
      mock_sso_with(email: 'apple@fruit.com', uid: '123456')

      visit 'enquiries/great-opportunity'

      expect(page).to be_an_enquiry_form
    end

    scenario 'when a user does not exist on our end' do
      mock_sso_with(email: 'apple@fruit.com', uid: '123456')

      visit 'enquiries/great-opportunity'

      expect(page).to be_an_enquiry_form
    end

    scenario 'when the SSO response is invalid' do
      OmniAuth.config.mock_auth[:exporting_is_great] = :invalid_credentials

      visit 'enquiries/great-opportunity'

      expect(page).to have_content 'We couldn’t sign you in'
      expect(page).to have_content 'invalid_credentials'
    end

    scenario 'when the user doesnt have a trade profile' do
      mock_sso_with(email: 'enquirer@exporter.com')

      visit 'enquiries/great-opportunity'

      fill_in_form
      click_on 'Apply now'

      expect(page).to have_content 'We noticed that you don\'t have a trade profile.'
    end

    scenario 'when the user has a trade profile' do
      skip('TODO: fix. get enquiries to save in has_many relation to user/opps')
      user = create(:user, email: 'enquirer@exporter.com')
      opportunity = create(:opportunity, :published)
      create(:enquiry, company_url: 'https://example.com', company_house_number: 'SC406536', user: user, opportunity: opportunity)

      allow_any_instance_of(ApplicationHelper).to receive(:trade_profile).with(:any).and_return 'http://export.great.gov.uk'

      mock_sso_with(email: 'enquirer@exporter.com')
      visit 'enquiries/' + opportunity.slug

      expect(page).to have_content 'We have identified that you have a trade profile.'
    end
  end

  scenario 'user enquiries are emailed to DIT' do
    allow(Figaro.env).to receive(:enquiries_cc_email).and_return('dit-cc@example.org')
    clear_email

    opportunity = create(:opportunity, status: 'publish')
    create(:sector)
    apply_to_opportunity(opportunity)
    enquiry = opportunity.enquiries.first

    opportunity.contacts.each do |contact|
      open_email(contact.email)
      expect(current_email).not_to be_nil
      expect(current_email.cc).to eq(['dit-cc@example.org'])
      expect(current_email).to have_link(opportunity.title)
      expect(current_email).to have_content(enquiry.company_name)
      expect(current_email).to have_content(enquiry.email)
    end

    open_email('dit-cc@example.org')
    expect(current_email).not_to be_nil
    expect(current_email).to have_link(opportunity.title)
    expect(current_email).to have_content(enquiry.company_name)
    expect(current_email).to have_content(enquiry.email)
    expect(current_email).to have_content('Details can be used for marketing by DIT and trusted partners: Y')
  end

  scenario 'DIT are not CCed if enquiries_cc_email not set' do
    allow(Figaro.env).to receive(:enquiries_cc_email)
    clear_email

    opportunity = create(:opportunity, status: 'publish')
    create(:sector)
    apply_to_opportunity(opportunity)

    opportunity.contacts.each do |contact|
      open_email(contact.email)
      expect(current_email).not_to be_nil
      expect(current_email.cc).to eq(nil)
    end
  end

  scenario 'invalid enquiries should be bounced back to edit form' do
    opportunity = create(:opportunity, status: 'publish')
    create(:sector)
    visit "enquiries/#{opportunity.slug}"

    click_on 'Apply now'
    expect(page).not_to have_content('Thank you')
  end

  private

  def be_an_enquiry_form
    have_selector('h1', text: 'Apply now')
  end

  def fill_in_form
    fill_in_your_details
    fill_in_company_details
    fill_in_exporting_experience
    tick_data_protection_checkbox
  end

  def fill_in_your_details
    fill_in 'First Name', with: Faker::Name.first_name
    fill_in 'Last Name', with: Faker::Name.last_name
    fill_in 'Telephone Number', with: Faker::PhoneNumber.phone_number
  end

  def fill_in_company_details
    fill_in 'Company Name', with: Faker::Company.name
    page.check "I don't have a Companies House Number"
    fill_in 'Company Address', with: Faker::Address.street_address
    fill_in 'Post Code', with: Faker::Address.postcode
    fill_in 'Company URL', with: Faker::Internet.url
  end

  def fill_in_exporting_experience
    select 'Not yet', from: 'Have you sold products or services to overseas customers?'
    select Sector.all.sample.name, from: 'Please indicate which sector you work in'
    fill_in 'Tell us how you can meet the requirements for this opportunity', with: Faker::Company.bs
  end

  def tick_data_protection_checkbox
    check 'I agree my details may be used for marketing'
  end

  def apply_to_opportunity(opportunity)
    visit "enquiries/#{opportunity.slug}"

    fill_in_form
    click_on 'Apply now'
  end
end
