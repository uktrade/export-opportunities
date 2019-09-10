# coding: utf-8
require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'users can apply for opportunities', js: true do
  before do
    mock_sso_with(email: 'email@example.com')
    create(:opportunity, slug: 'great-opportunity', status: :publish)
    create(:sector)
  end

  scenario 'unless the opportunity has expired' do
    expired_opportunity = create(:opportunity, :expired, status: :publish, slug: 'expired-opp')
    visit '/export-opportunities/enquiries/expired-opp'

    expect(page).not_to be_an_enquiry_form
    expect(page).to have_content expired_opportunity.title
    expect(page).to have_content t('opportunity.expired')
  end

  scenario 'when they are logged in as an individual', focus: true do
    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).not_to have_field 'Email Address'

    fill_in_form_as_individual
    click_on 'Submit'

    expect(page).to have_content 'Your expression of interest has been submitted and will be reviewed'
    expect(page).to have_link 'View your expressions of interest to date'

    visit '/export-opportunities/enquiries/great-opportunity'
  end

  scenario 'when they are logged in as a limited company' do
    # Make the User a Limited Company!
    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).not_to have_field 'Email Address'

    fill_in_form_as_limited_company
    click_on 'Submit'

    expect(page).to have_content 'Your expression of interest has been submitted and will be reviewed'
    expect(page).to have_link 'View your expressions of interest to date'

    visit '/export-opportunities/enquiries/great-opportunity'
  end

  scenario 'unless the SSO response is invalid' do
    if Figaro.env.bypass_sso?
      provider = :developer
    else
      provider = :exporting_is_great
    end
    OmniAuth.config.mock_auth[provider] = :invalid_credentials

    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).to have_content 'We couldn’t sign you in'
    expect(page).to have_content 'invalid_credentials'
  end

  scenario 'user can apply with more than 1100 characters in company description, first 1100 will be saved' do
    opportunity = create(:opportunity, status: 'publish')
    create(:sector)

    visit "/export-opportunities/enquiries/#{opportunity.slug}"

    fill_in_form_as_individual
    fake_description = Faker::Lorem.characters(1102)

    fill_in :enquiry_company_explanation, with: fake_description

    click_on 'Submit'

    # form will crop our last 2 chars+terminating character and save company explanation
    expect(Enquiry.first.company_explanation).to eq(fake_description[0..-3])
    expect(page).to have_content('Thank you')
  end

  scenario 'user can apply with exactly 1100 characters in company description', js: true do
    opportunity = create(:opportunity, status: 'publish')
    create(:sector)

    visit "/export-opportunities/enquiries/#{opportunity.slug}"

    fill_in_form_as_individual
    fake_description = Faker::Lorem.characters(1100)
    fill_in :enquiry_company_explanation, with: fake_description

    click_on 'Submit'

    expect(page).to have_content('Thank you')
  end

  scenario 'user enquiries are emailed to DIT' do
    allow(Figaro.env).to receive(:enquiries_cc_email).and_return('dit-cc@example.org')
    clear_email

    opportunity = create(:opportunity, status: 'publish')
    create(:sector)
    apply_to_opportunity(opportunity)
    enquiry = opportunity.enquiries.first
    reply_by_date = (Date.today + 7.days).strftime("%d %B %Y")

    opportunity.contacts.each do |contact|
      open_email(contact.email)
      expect(current_email).not_to be_nil
      expect(current_email.cc).to eq(['dit-cc@example.org'])
      expect(current_email).to have_content(opportunity.title)
      expect(current_email).to have_content(enquiry.company_name)
      expect(current_email).to have_content("You need to respond to the enquiry using the correct reply template in the admin centre by #{reply_by_date}")
    end

    open_email('dit-cc@example.org')
    expect(current_email).not_to be_nil
    expect(current_email).to have_content(opportunity.title)
    expect(current_email).to have_content(enquiry.company_name)
    expect(current_email).to have_content('Remember to record a new interaction in Data Hub.')
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
    visit "/export-opportunities/enquiries/#{opportunity.slug}"

    click_on 'Submit'
    expect(page).not_to have_content('Thank you')
  end

  private

  def be_an_enquiry_form
    have_selector('h1', text: 'You are expressing an interest in')
  end

  def fill_in_form_as_individual
    fill_in 'Job title (optional)', with: Faker::Name.prefix
    fill_in 'Phone Number (optional)', with: Faker::PhoneNumber.phone_number

    fill_in 'Business name', with: Faker::Company.name
    fill_in 'Companies House number (optional)',
      with: Faker::Number.between(10000000, 99999999)
    fill_in 'Address', with: Faker::Address.street_address
    fill_in 'Post code', with: Faker::Address.postcode

    check "Add trading address (optional)"
    fill_in 'Trading address', with: Faker::Address.postcode
    fill_in 'Trading post code', with: Faker::Address.postcode
    
    fill_in 'Your business web address (optional)', with: Faker::Internet.url
    select Sector.all.sample.name, from: "Which industry is your company in?"
    select 'Not yet', from: 'Have you sold products or services to overseas?'
    fill_in :enquiry_company_explanation, with: Faker::Company.bs
  end

  def fill_in_form_as_limited_company
    fill_in 'Phone Number (optional)', with: Faker::PhoneNumber.phone_number

    check "Add trading address (optional)"
    fill_in 'Trading address', with: Faker::Address.postcode
    fill_in 'Trading post code', with: Faker::Address.postcode

    fill_in 'Your business web address (optional)', with: Faker::Internet.url
    select Sector.all.sample.name, from: "Which industry is your company in?"
    select 'Not yet', from: 'Have you sold products or services to overseas?'
    fill_in :enquiry_company_explanation, with: Faker::Company.bs
  end

  def apply_to_opportunity(opportunity)
    visit "/export-opportunities/enquiries/#{opportunity.slug}"

    fill_in_form_as_individual
    click_on 'Submit'
  end
end
