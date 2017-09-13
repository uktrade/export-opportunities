require 'rails_helper'

feature 'Looking up company details through Companies House API', js: true do
  before do
    # @TODO
    # These tests were written with this set to `false`, so
    # they will break if you remove these before/after blocks.
    #
    # When you come to fix the bugs this setting was hiding (!)
    # please remove them.
    Capybara.ignore_hidden_elements = false
  end

  after do
    Capybara.ignore_hidden_elements = true
  end

  before :each do
    mock_sso_with(email: 'email@example.com')
  end

  scenario 'have a button to look up company' do
    opportunity = create(:opportunity, status: 'publish')
    visit opportunity_path(opportunity)

    within '.opportunity__information' do
      click_on 'Submit your proposal'
    end

    expect(find_field('enquiry_company_name').value).to be_blank
    expect(find_field('enquiry_company_house_number').value).to be_blank
    expect(find_field('enquiry_company_postcode').value).to be_blank

    expect(page).to have_content 'Search Companies House'

    within '.your-business' do
      fill_in 'enquiry_company_name', with: 'dxw'
    end

    stub_finder_call(items: example_company_house_response)

    click_on 'Search Companies House'

    expect(page).to have_selector('#ch_search-results ul li')
    expect(page).to have_content 'DXW LTD'

    click_on 'DXW LTD'

    expect(find_field('enquiry_company_name').value).to eql('DXW LTD')
    expect(find_field('enquiry_company_house_number').value).to eql('09421914')
    expect(find_field('enquiry_company_postcode').value).to eql('W1U 8EW')
  end

  scenario 'when the user first shows and hides the fields which allow the form to be submitted without a companies house number' do
    Capybara.ignore_hidden_elements = true
    opportunity = create(:opportunity, status: 'publish')

    visit "/enquiries/#{opportunity.slug}"
    within '.your-business' do
      page.check "I don't have a Companies House Number"
      page.uncheck "I don't have a Companies House Number"
      fill_in 'enquiry_company_name', with: 'dxw'
    end

    stub_finder_call(items: example_company_house_response)

    click_on 'Search Companies House'

    expect(page).to have_selector('#ch_search-results ul li')
    expect(page).to have_content 'DXW LTD'

    click_on 'DXW LTD'

    expect(find_field('enquiry_company_house_number').value).to eql('09421914')
  end

  scenario 'enquiries can search multiple times without refreshing the page' do
    opportunity = create(:opportunity, status: 'publish')
    visit opportunity_path(opportunity)

    within '.opportunity__information' do
      click_on 'Submit your proposal'
    end

    within '.your-business' do
      fill_in 'enquiry_company_name', with: 'dxw'
    end

    stub_finder_call(items: example_company_house_response)

    click_on 'Search Companies House'

    expect(page).to have_selector('#ch_search-results ul li')
    expect(page).to have_content 'DXW LTD'

    click_on 'DXW LTD'

    expect(find_field('enquiry_company_name').value).to eql('DXW LTD')
    expect(find_field('enquiry_company_house_number').value).to eql('09421914')
    expect(find_field('enquiry_company_postcode').value).to eql('W1U 8EW')

    within '.your-business' do
      fill_in 'enquiry_company_name', with: 'dxw'
    end

    click_on 'Search Companies House'

    expect(page).to have_selector('#ch_search-results ul li')
    expect(page).to have_content 'DXW test'

    click_on 'DXW test'

    expect(find_field('enquiry_company_name').value).to eql('DXW test')
    expect(find_field('enquiry_company_house_number').value).to eql('07593934')
    expect(find_field('enquiry_company_postcode').value).to eql('W1B 3HH')
  end

  scenario 'enquirers can search then change their mind and apply without a company number' do
    opportunity = create(:opportunity, status: 'publish')
    sector = create(:sector)
    visit opportunity_path(opportunity)

    within '.opportunity__information' do
      click_on 'Submit your proposal'
    end

    within '.your-business' do
      fill_in 'enquiry_company_name', with: 'dxw'
    end

    stub_finder_call(items: example_company_house_response)

    click_on 'Search Companies House'
    find(:css, '#enquiry_company_house_number').set(true)

    fill_in 'enquiry_company_address', with: 'Hoxton Square'
    fill_in 'enquiry_company_postcode', with: 'AB1 2CD'
    fill_in 'enquiry_company_url', with: 'http://example.org/'

    # fill out the other fields to pass JS validation
    fill_in 'enquiry_first_name', with: 'Harry'
    fill_in 'enquiry_last_name', with: 'Metcalfe'
    fill_in 'enquiry_company_telephone', with: '123456789'

    fill_in 'enquiry_company_explanation', with: 'We are awesome.'
    select sector.name, from: 'enquiry_company_sector'
    select 'Not yet', from: 'enquiry_existing_exporter'
    click_on 'Submit'

    expect(opportunity.enquiries.size).to eq(1)
  end

  scenario 'allow an enquirer to view their own company details on the CH site' do
    opportunity = create(:opportunity, status: 'publish')
    visit opportunity_path(opportunity)

    within '.opportunity__information' do
      click_on 'Submit your proposal'
    end

    within '.your-business' do
      fill_in 'enquiry_company_name', with: 'dxw'
    end

    stub_finder_call(items: example_company_house_response)

    click_on 'Search Companies House'
    expect(page).to have_link('(View on Companies House website)',
      href: 'https://beta.companieshouse.gov.uk/company/09421914')
  end

  def stub_finder_call(result_body = {})
    result = { items_per_page: 50,
               items: [],
               kind: 'search#companies',
               total_results: 0,
               page_number: 1,
               start_index: 0 }.with_indifferent_access
    result.merge!(result_body)
    body = result['items'].map { |company| CompanyDetail.new(company.to_h) }
    allow_any_instance_of(CompanyHouseFinder).to receive(:call).and_return(body)
  end

  def example_company_house_response
    [
      {
        'links' => { 'self' => '/company/09421914' },
        'company_type' => 'ltd',
        'address' => { 'locality' => 'London', 'address_line_1' => '55 Baker Street 55 Baker Street', 'postal_code' => 'W1U 8EW', 'address_line_2' => 'Floor 7' },
        'kind' => 'searchresults#company',
        'description_identifier' => ['incorporated-on'],
        'description' => '09421914 - Incorporated on  4 February 2015',
        'matches' => { 'title' => [1, 3] },
        'company_status' => 'active',
        'snippet' => '55 Baker Street 55 Baker Street, Floor 7, London, W1U 8EW',
        'date_of_creation' => '2015-02-04',
        'company_number' => '09421914',
        'title' => 'DXW LTD',
      }.with_indifferent_access,
      {
        'date_of_creation' => '2011-04-06',
        'kind' => 'searchresults#company',
        'company_status' => 'active',
        'company_type' => 'ltd',
        'links' => { 'self' => '/company/07593934' },
        'description_identifier' => ['incorporated-on'],
        'address' => { 'address_line_1' => '3rd Floor 207 Regent Street', 'postal_code' => 'W1B 3HH', 'locality' => 'London' },
        'description' => '07593934 - Incorporated on  6 April 2011',
        'company_number' => '07593934',
        'snippet' => '3rd Floor 207 Regent Street, London, W1B 3HH',
        'title' => 'DXW test',
      }.with_indifferent_access,
    ]
  end
end
