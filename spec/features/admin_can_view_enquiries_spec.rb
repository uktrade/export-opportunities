require 'rails_helper'

feature 'admin can view enquiries' do
  scenario 'viewing a list of all enquiries' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    login_as(admin)
    visit admin_opportunities_path

    click_on 'Enquiries'
    expect(page).to have_content(enquiry.company_name)
  end

  scenario 'viewing a list of all NOT replied enquiries and all replied enquiries' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    another_enquiry = create(:enquiry)
    es = create(:enquiry_response, response_type: 1, enquiry: enquiry)
    # because it's a hash
    es['completed_at'] = Time.zone.now
    es.save!

    login_as(admin)
    visit admin_opportunities_path

    click_on 'Enquiries'

    expect(page).to have_content(enquiry.company_name)
    expect(page).to have_content(another_enquiry.company_name)

    select 'To reply', from: 'status'
    click_on 'Search'
    expect(page).to_not have_content(enquiry.company_name)
    expect(page).to have_content('7 days left')
    expect(page).to have_content(another_enquiry.company_name)

    select 'Replied', from: 'status'
    click_on 'Search'
    expect(page).to have_content('Replied 0 days after')
    expect(page).to have_content(enquiry.company_name)
  end

  scenario 'viewing a list of all NOT replied enquiries and all replied enquiries as an uploader' do
    uploader = create(:editor, role: 1, service_provider: ServiceProvider.create(name: 'athena'))
    opportunity = create(:opportunity, service_provider: uploader.service_provider)

    enquiry = create(:enquiry, opportunity: opportunity)
    another_enquiry = create(:enquiry, opportunity: opportunity)
    es = create(:enquiry_response, response_type: 1, enquiry: enquiry)
    # because it's a hash
    es['completed_at'] = Time.zone.now
    es.save!

    login_as(uploader)
    visit admin_opportunities_path

    click_on 'Enquiries'

    expect(page).to have_content(enquiry.company_name)
    expect(page).to have_content(another_enquiry.company_name)

    select 'To reply', from: 'status'
    click_on 'Search'
    expect(page).to_not have_content(enquiry.company_name)
    expect(page).to have_content('7 days left')
    expect(page).to have_content(another_enquiry.company_name)

    select 'Replied', from: 'status'
    click_on 'Search'

    expect(page).to have_content('Replied 0 days after')
    expect(page).to have_content(enquiry.company_name)
  end

  scenario 'viewing which enquiries are replied' do
    admin = create(:admin)

    enquiry = create(:enquiry, company_name: 'UK Boathouses Inc', created_at: DateTime.new(2017, 5, 1).utc)
    create(:enquiry_response, enquiry: enquiry, completed_at: nil)

    create(:enquiry, company_name: 'UK Leaky Boathouses', created_at: DateTime.new(2017, 6, 1).utc)

    login_as(admin)

    visit admin_opportunities_path

    click_on 'Enquiries'

    expect(page).to have_content(enquiry.company_name)
    expect(page).to have_selector('th', text: 'Company')
    expect(page).to have_selector('th', text: 'Opportunity')
    expect(page).to have_selector('th', text: 'Applied On')
    expect(page).to have_selector('th', text: 'Status')

    first_row = page.find('.results tbody tr:nth-child(1)')
    second_row = page.find('.results tbody tr:nth-child(2)')

    expect(first_row).to have_content('UK Leaky Boathouses')
    expect(first_row).to have_content('days overdue')

    expect(second_row).to have_content('UK Boathouses Inc')
    expect(second_row).to have_content('Pending')
  end

  scenario 'list of enquiries can be paginated', skip: true do
    admin = create(:admin)
    modern_enquiry = create(:enquiry, company_name: 'OCP')
    create_list(:enquiry, 24)
    historic_enquiry = create(:enquiry, company_name: 'Ye Olde Company', created_at: Time.zone.local(1066, 10, 14))

    login_as(admin)
    visit admin_opportunities_path

    click_on 'Enquiries'

    expect(page).to have_link(modern_enquiry.id)
    expect(page).not_to have_link(historic_enquiry.id)

    click_on 'Page 2'

    expect(page).not_to have_link(modern_enquiry.id)
    expect(page).to have_link(historic_enquiry.id)
  end

  scenario 'view details of an enquiry' do
    admin = create(:admin)
    enquiry = create(:enquiry)
    create(:enquiry_response, response_type: 1, enquiry: enquiry)
    login_as(admin)
    visit admin_opportunities_path

    click_on 'Enquiries'
    expect(page).to have_content(enquiry.id)

    click_on enquiry.id

    expect(page).to have_link(enquiry.opportunity.title)
    expect(page).to have_content(enquiry.company_name)
    expect(page).to have_content(enquiry.email)
    expect(page).to have_content(enquiry.first_name)
    expect(page).to have_content(enquiry.last_name)
    expect(page).to have_content(enquiry.company_telephone)
    expect(page).to have_content(enquiry.company_address)
    expect(page).to have_content(enquiry.company_postcode)
    expect(page).to have_content(enquiry.company_url)
    expect(page).to have_content(enquiry.company_explanation)
    expect(page).to have_content(enquiry.company_sector)
  end

  scenario 'download a csv of enquiries' do
    skip('refactor with new async process')
    admin = create(:admin)

    # We need quite a detailed setup here to allow us to check each field.
    country = create(:country)
    service_provider = create(:service_provider)
    opportunity = create(:opportunity, countries: [country], service_provider: service_provider)
    user = create(:user)
    enquiry = create(:enquiry, user: user, opportunity: opportunity, data_protection: true, created_at: 1.day.ago)

    login_as(admin)
    visit admin_opportunities_path

    click_on 'Enquiries'
    expect(page).to have_button('Generate report')

    click_on 'Generate report'

    expect(page.response_headers).to include 'Content-Type' => 'text/csv'

    expect(page).to have_content(enquiry.company_name)
    expect(page).to have_content(enquiry.first_name)
    expect(page).to have_content(enquiry.last_name)
    expect(page).to have_content(enquiry.company_address)
    expect(page).to have_content(enquiry.company_postcode)
    expect(page).to have_content(enquiry.company_telephone)
    expect(page).to have_content(enquiry.created_at.strftime('%Y/%m/%d %H:%M'))
    expect(page).to have_content(enquiry.company_sector)
    expect(page).to have_content(enquiry.opportunity.title)
    expect(page).to have_content(enquiry.opportunity.countries[0].name)
    expect(page).to have_content(user.email)
    expect(page).to have_content(enquiry.opportunity.service_provider.name)
    expect(page).to have_content(enquiry.company_house_number)
    expect(page).to have_content(enquiry.company_url)
    expect(page).to have_content(enquiry.existing_exporter)
    expect(page).to have_content(enquiry.company_explanation)
  end

  scenario 'download a csv of enquiries for a given date range.' do
    skip('refactor with new async process')
    admin = create(:admin)

    in_range = create(:enquiry, created_at: Date.new(2016, 6, 15))
    out_of_range = create(:enquiry, created_at: Date.new(2016, 7, 15))

    login_as(admin)
    visit admin_opportunities_path

    click_on 'Enquiries'
    expect(page).to have_button('Generate report')

    select '2016', from: 'created_at_from_year'
    select 'June', from: 'created_at_from_month'
    select '1', from: 'created_at_from_day'

    select '2016', from: 'created_at_to_year'
    select 'July', from: 'created_at_to_month'
    select '1', from: 'created_at_to_day'

    click_on 'Generate report'

    expect(page.response_headers).to include 'Content-Disposition' => 'attachment; filename="eig-enquiries-2016-06-01-2016-07-01.csv"'
    expect(page.response_headers).to include 'Content-Type' => 'text/csv'

    expect(page).to have_content(in_range.company_name)
    expect(page).not_to have_content(out_of_range.company_name)
  end

  scenario 'CSV includes all entries in range' do
    skip('refactor with new async process')
    admin = create(:admin)
    enquiries = create_list(:enquiry, 50, created_at: 3.days.ago)
    login_as(admin)
    visit admin_opportunities_path

    click_on 'Enquiries'
    expect(page).to have_button('Generate report')

    week_ago = 7.days.ago
    select week_ago.year.to_s, from: 'created_at_from_year'
    select Date::MONTHNAMES[week_ago.month], from: 'created_at_from_month'
    select week_ago.day.to_s, from: 'created_at_from_day'

    today = Time.zone.today
    select today.year.to_s, from: 'created_at_to_year'
    select Date::MONTHNAMES[today.month], from: 'created_at_to_month'
    select today.day.to_s, from: 'created_at_to_day'

    click_on 'Generate report'

    enquiries.each do |enquiry|
      expect(page).to have_content(enquiry.company_name)
    end
  end

  scenario 'enquiries in individual opportunity page have correct trade profile and CH link' do
    admin = create(:admin)
    login_as(admin)

    sectors = create_list(:sector, 3)
    types = create_list(:type, 5)
    countries = [create(:country, exporting_guide_path: '/somelink')]

    opportunity = create(:opportunity, status: 'publish', sectors: sectors, types: types, countries: countries)
    enquiry = create(:enquiry, company_house_number: '12345678', opportunity: opportunity)

    allow_any_instance_of(ApplicationHelper).to receive(:companies_house_url).with('12345678').and_return('https://beta.companieshouse.gov.uk/company/10804351')
    allow_any_instance_of(ApplicationHelper).to receive(:trade_profile).with('12345678').and_return('https://trade.great.gov.uk/amazon')

    visit admin_opportunity_path(opportunity.id)

    expect(page).to have_link(enquiry.company_name, href: 'https://beta.companieshouse.gov.uk/company/10804351')
    expect(page).to have_link(enquiry.company_name, href: 'https://trade.great.gov.uk/amazon')
  end

  scenario 'can not generate multiple enquiry responses' do
    opportunity = create(:opportunity)
    enquiry = create(:enquiry, company_house_number: '12345678', opportunity: opportunity)
    create(:enquiry_response, enquiry: enquiry)

    expect { create(:enquiry_response, enquiry: enquiry) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
