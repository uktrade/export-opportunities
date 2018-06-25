require 'rails_helper'
require 'capybara/email/rspec'

feature 'JS-on adds Companies House API lookup', js: true do
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
    @user = create(:user, email: 'test@example.com')
    login_as @user, scope: :user
  end

  # JS functionality adds Companies House input show/hide
  scenario 'ExpanderControl will show and hide Companies House input' do
    opportunity = create(:opportunity, status: 'publish')
    visit opportunity_path(opportunity)
    click_on 'Submit your proposal'

    # control created
    expander_control = find_field('has_companies_house_number')
    expect(expander_control['class']).to include('ExpanderControl')

    # target created
    expander_control_target = find('#' + expander_control['aria-controls']) 
    expect(expander_control_target['class']).to include('Expander')

    # control unchecked and expander open
    expect(expander_control.checked?).to be(false)
    expect(expander_control['aria-expanded']).to eql('true')
    expect(expander_control_target['class']).to_not include('collapsed')

    # control checked and expander closed
    expander_control.trigger('click')
    expect(expander_control.checked?).to be(true)
    expect(expander_control['aria-expanded']).to eql('false')
    expect(expander_control_target['class']).to include('collapsed')
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
        'company_status' => 'active',
        'snippet' => '55 Baker Street 55 Baker Street, Floor 7, London, W1U 8EW',
        'date_of_creation' => '2015-02-04',
        'company_number' => '09421914',
        'title' => 'DXW LTD',
        'matches' => { 'title' => [1, 3] },
      }.with_indifferent_access,
      {
        'links' => { 'self' => '/company/07593934' },
        'company_type' => 'ltd',
        'address' => { 'address_line_1' => '3rd Floor 207 Regent Street', 'postal_code' => 'W1B 3HH', 'locality' => 'London' },
        'kind' => 'searchresults#company',
        'description_identifier' => ['incorporated-on'],
        'description' => '07593934 - Incorporated on  6 April 2011',
        'company_status' => 'active',
        'snippet' => '3rd Floor 207 Regent Street, London, W1B 3HH',
        'date_of_creation' => '2011-04-06',
        'company_number' => '07593934',
        'title' => 'DXW test',
      }.with_indifferent_access,
    ]
  end
end
