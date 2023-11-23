# coding: utf-8
require 'rails_helper'
require 'capybara/email/rspec'

RSpec.feature 'users can apply for opportunities', js: true, sso: true do
  before do
    mock_sso_with(email: 'email@example.com')
    create(:opportunity, slug: 'great-opportunity', status: :publish)
    create(:sector)

    allow(DirectoryApiClient).to receive(:private_company_data){ nil }
  end

  scenario 'unless the opportunity has expired' do
    expired_opportunity = create(:opportunity, :expired, status: :publish, slug: 'expired-opp')
    visit '/export-opportunities/enquiries/expired-opp'

    expect(page).not_to be_an_enquiry_form
    expect(page).to have_content expired_opportunity.title
    expect(page).to have_content t('opportunity.expired')
  end

  scenario 'when they are logged in as an individual - no response from directory-api' do
    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).not_to have_field 'Email Address'

    fill_in_form_as_individual
    click_on 'Submit'

    expect(page).to have_content 'Your expression of interest has been submitted and will be reviewed'
    expect(page).to have_link 'View your expressions of interest to date'

    visit '/export-opportunities/enquiries/great-opportunity'
  end

  scenario 'when they are logged in as an individual - complete data' do
    allow(DirectoryApiClient).to receive(:user_data){{
      id: 1,
      email: "john@example.com",
      hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
      user_profile: {
        first_name: "John",
        last_name: "Bull",
        job_title: "Owner",
        mobile_phone_number: "123123123"
      }
    }}
    allow(DirectoryApiClient).to receive(:private_company_data){{
      'name': 'Joe Construction',
      'mobile_number': '5551234',
      'address_line_1': '123 Joe house',
      'address_line_2': 'Joe Street',
      'country': 'Uk',
      'postal_code': 'N1 4DF',
      'number': '12341234',
      'website': 'www.example.com',
      'summary': 'good company',
      'company_type': ''
    }}
    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).not_to have_field 'Email Address'

    fill_in_form_as_individual
    click_on 'Submit'

    expect(page).to have_content 'Your expression of interest has been submitted and will be reviewed'
    expect(page).to have_link 'View your expressions of interest to date'

    visit '/export-opportunities/enquiries/great-opportunity'
  end

  scenario 'when they are logged in as an individual - incomplete data' do
    allow(DirectoryApiClient).to receive(:user_data){{
      id: nil,
      email: "",
      hashed_uuid: "",
      user_profile: {
        first_name: "",
        last_name: "",
        job_title: "",
        mobile_phone_number: ""
      }
    }}
    allow(DirectoryApiClient).to receive(:private_company_data){{
      'name': '',
      'mobile_number': '',
      'address_line_1': '',
      'address_line_2': '',
      'country': '',
      'postal_code': '',
      'number': '',
      'website': '',
      'summary': '',
      'company_type': ''
    }}
    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).not_to have_field 'Email Address'

    fill_in_form_personal_data_if_no_profile
    fill_in_form_as_individual
    click_on 'Submit'

    expect(page).to have_content 'Your expression of interest has been submitted and will be reviewed'
    expect(page).to have_link 'View your expressions of interest to date'

    visit '/export-opportunities/enquiries/great-opportunity'
  end

  scenario 'when they are logged in as a limited company - complete data' do
    allow(DirectoryApiClient).to receive(:user_data){{
      id: 1,
      email: "john@example.com",
      hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
      user_profile: {
        first_name: "John",
        last_name: "Bull",
        job_title: "Owner",
        mobile_phone_number: "123123123"
      }
    }}
    allow(DirectoryApiClient).to receive(:private_company_data){{
      'name': 'Joe Construction',
      'mobile_number': '5551234',
      'address_line_1': '123 Joe house',
      'address_line_2': 'Joe Street',
      'country': 'Uk',
      'postal_code': 'N1 4DF',
      'number': '12341234',
      'website': 'www.example.com',
      'summary': 'good company',
      'company_type': 'COMPANIES_HOUSE'
    }}
    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).not_to have_field 'Email Address'

    fill_in_form_as_limited_company
    click_on 'Submit'

    expect(page).to have_content 'Your expression of interest has been submitted and will be reviewed'
    expect(page).to have_link 'View your expressions of interest to date'

    visit '/export-opportunities/enquiries/great-opportunity'
  end


  scenario 'when they are logged in as a sole trader' do
    allow(DirectoryApiClient).to receive(:user_data){{
      id: 1,
      email: "john@example.com",
      hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
      user_profile: {
        first_name: "John",
        last_name: "Bull",
        job_title: "Owner",
        mobile_phone_number: "123123123"
      }
    }}
    allow(DirectoryApiClient).to receive(:private_company_data){{
      'name': 'Joe Construction',
      'mobile_number': '5551234',
      'address_line_1': '123 Joe house',
      'address_line_2': 'Joe Street',
      'country': 'Uk',
      'postal_code': 'N1 4DF',
      'website': 'www.example.com',
      'summary': 'good company',
      'company_type': 'SOLE_TRADER'
    }}
    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).not_to have_field 'Email Address'

    fill_in_form_as_limited_company
    click_on 'Submit'

    expect(page).to have_content 'Your expression of interest has been submitted and will be reviewed'
    expect(page).to have_link 'View your expressions of interest to date'

    visit '/export-opportunities/enquiries/great-opportunity'
  end


  scenario 'when they are logged in as a limited company - incomplete data' do
    allow(DirectoryApiClient).to receive(:user_data){{
      id: nil,
      email: "",
      hashed_uuid: "",
      user_profile: {
        first_name: "",
        last_name: "",
        job_title: "",
        mobile_phone_number: ""
      }
    }}
    allow(DirectoryApiClient).to receive(:private_company_data){{
      'name': '',
      'mobile_number': '',
      'address_line_1': '',
      'address_line_2': '',
      'country': '',
      'postal_code': '',
      'number': '',
      'website': '',
      'summary': '',
      'company_type': 'COMPANIES_HOUSE'
    }}
    visit '/export-opportunities/enquiries/great-opportunity'

    expect(page).not_to have_field 'Email Address'

    fill_in_form_personal_data_if_no_profile
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

  scenario 'user enquiries are emailed to DBT' do
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

  def fill_in_form_personal_data_if_no_profile
    if has_field?('First Name')
      fill_in 'First name', with: Faker::Name.first_name
    end
    if has_field?('Last Name')
      fill_in 'Last name', with: Faker::Name.last_name
    end
  end

  def fill_in_form_as_individual
    if has_field?('enquiry_job_title')
      fill_in 'Job title (optional)', with: Faker::Name.prefix
    end
    if has_field?('enquiry_company_telephone')
      fill_in 'Phone number (optional)', with: Faker::PhoneNumber.phone_number
    end
    if has_field?('enquiry_company_name')
        fill_in 'Business name', with: Faker::Company.name
        fill_in 'Companies House number (optional)',
          with: Faker::Number.between(from: 10000000, to: 99999999)
        fill_in 'Address', with: Faker::Address.street_address
        fill_in 'Post code', with: Faker::Address.postcode
    end
    if has_field?('add_trading_address')
    find_by_id("add_trading_address", visible: false).trigger('click')
        fill_in 'Trading address', with: Faker::Address.postcode
        fill_in 'Trading post code', with: Faker::Address.postcode
    end
    if has_field?('enquiry_company_url')
        fill_in 'Your business web address (optional)', with: Faker::Internet.url
    end
    select Sector.all.sample.name, from: "Which industry is your company in?"
    select 'Not yet', from: 'enquiry_existing_exporter'
    fill_in :enquiry_company_explanation, with: Faker::Company.bs
  end

  def fill_in_form_as_limited_company
    if has_field?('enquiry_company_telephone')
      fill_in 'Phone number (optional)', with: Faker::PhoneNumber.phone_number
    end
    if has_field?('enquiry_company_postcode')
      fill_in 'Post code', with: Faker::Address.postcode
    end

    if has_field?('add_trading_address')
        find_by_id("add_trading_address", visible: false).trigger('click')
        fill_in 'Trading address', with: Faker::Address.postcode
        fill_in 'Trading post code', with: Faker::Address.postcode
    end

    if has_field?('enquiry_company_url')
        fill_in 'Your business web address (optional)', with: Faker::Internet.url
    end
    select Sector.all.sample.name, from: "Which industry is your company in?"
    select 'Not yet', from: 'enquiry_existing_exporter'
    fill_in :enquiry_company_explanation, with: Faker::Company.bs
  end

  def apply_to_opportunity(opportunity)
    allow(DirectoryApiClient).to receive(:user_data){{
      id: 1,
      email: "john@example.com",
      hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
      user_profile: {
        first_name: "John",
        last_name: "Bull",
        job_title: "Owner",
        mobile_phone_number: "123123123"
      }
    }}
    allow(DirectoryApiClient).to receive(:private_company_data){{
      'name': 'Joe Construction',
      'mobile_number': '5551234',
      'address_line_1': '123 Joe house',
      'address_line_2': 'Joe Street',
      'country': 'Uk',
      'postal_code': 'N1 4DF',
      'number': '12341234',
      'website': 'www.example.com',
      'summary': 'good company',
      'company_type': ''
    }}
    visit "/export-opportunities/enquiries/#{opportunity.slug}"

    fill_in_form_as_individual
    click_on 'Submit'
  end
end
