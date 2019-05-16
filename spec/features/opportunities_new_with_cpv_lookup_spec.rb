require 'rails_helper'
require 'capybara/email/rspec'

feature 'JS-on adds CPV code lookup functionality', js: true do
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
    @content = get_content('admin/opportunities')

    create(:type, name: 'Public Sector')
    create(:value, name: 'More than £100k')
    create(:country, name: 'America')
    create(:sector, name: 'Aerospace')
    create(:supplier_preference)
    service_provider = create(:service_provider, name: 'Italy Rome')
    uploader = create(:uploader, service_provider: service_provider)
    login_as(uploader)

    visit admin_opportunities_path
    click_on 'New opportunity'
  end

  # JS functionality is available and active
  scenario 'input will be enhanced with lookup functionality' do
    # Make sure we're on the right page
    expect(page.body).to have_text('Create a new export opportunity')

    # Field has been enhanced (check for class name applied by JS)
    cpv_input_field = find_field('opportunity[opportunity_cpv_ids][]')
    expect(cpv_input_field['class']).to include('CpvCodeLookup')

    # Clear button created
    cpv_input_clear = find_button('Clear value')
    expect(cpv_input_clear).to be_truthy

    # Adds a dropdown element
    cpv_input_dropdown = find('#' + cpv_input_field['aria-controls'])
    expect(cpv_input_dropdown).to be_truthy

    # CPV url constant is set
    expect(js_variable('dit.constants.CPV_CODE_LOOKUP_URL')).to include('api/cn/cpv')
  end

  # JS functionality allows CPV lookup and selection
  scenario 'Entering some text will fetch CPV data' do
    query = 'food'
    url = js_variable('dit.constants.CPV_CODE_LOOKUP_URL') + '?format=json&description=' + query
    stub_jquery_ajax(url, cpv_search_response)

    # Make sure we're on the right page
    expect(page.body).to have_text('Create a new export opportunity')

    # Get the enhancement elements
    cpv_input_field = find_field('opportunity[opportunity_cpv_ids][]')
    cpv_input_dropdown = find('#' + cpv_input_field['aria-controls'])

    # Check the initial state
    expect(cpv_input_field['aria-expanded']).to eql('false')
    expect(cpv_input_field.value).to eql('')

    # CPV lookup information is fetched when user enters data
    cpv_input_field.send_keys(query)

    # Wait for $.ajax functionality and DOM manipulation to finish
    sleep 1

    # Lookup data is presented to user
    expect(cpv_input_field['aria-expanded']).to eql('true')
    expect(cpv_input_dropdown['innerHTML']).to include('150120100080: Pig fat - For industrial uses other than manufacture')

    # User selection will populate CPV field
    cpv_choice = find('li', text: 'Pig fat - For industrial uses other than manufacture')
    cpv_choice.trigger('click')

    expect(cpv_input_field.value).to eql('150120100080: Pig fat - For industrial uses other than manufacture')
  end

  # JS functionality will clear CPV selections
  scenario 'Value can be cleared by the provided button' do
    # Make sure we're on the right page
    expect(page.body).to have_text('Create a new export opportunity')

    # Get the enhancement elements
    cpv_input_field = find_field('opportunity[opportunity_cpv_ids][]')
    cpv_input_clear = find_button('Clear value')

    # Manually set a value to simulate either on page load or lookup population
    cpv_input_field.set('0000 - some value')
    expect(cpv_input_field.value).to eql('0000 - some value')

    # Activate the clear and check it worked
    cpv_input_clear.trigger('click')
    expect(cpv_input_field.value).to eql('')
  end

  # Page specific JS functionality will add multiple field capability
  scenario 'Can add more than one CPV field and value' do
    # Make sure we're on the right page
    expect(page.body).to have_text('Create a new export opportunity')

    # Check initial elements
    page.assert_selector('.CpvCodeLookup', count: 1)
    page.assert_selector('.CpvCodeLookupClear', count: 1)

    # Activate the 'Add another code' functionality
    cpv_input_multiplier = find(:css, '.CpvLookupController')
    cpv_input_multiplier.trigger('click')

    # Check initial elements (again)
    page.assert_selector('.CpvCodeLookup', count: 2)
    page.assert_selector('.CpvCodeLookupClear', count: 2)
  end

  # EXAMPLE CPV search URL and RESPONSE
  # -----------------------------------------------------------------------
  # URL =
  # https://www.great.gov.uk/search?q=food
  #
  # RESPONSE =
  def cpv_search_response
    JSON.generate(
      [
        {
          'order': '1971397',
          'level': '5',
          'code': '150110100080',
          'parent': '150110000080',
          'code2': '1501 10 10',
          'parent2': '1501 10',
          'description': '-- For industrial uses other than manufacture',
          'english_text': 'Lard',
          'parent_description': 'Lard',
        }, {
          'order': '1971400',
          'level': '5',
          'code': '150120100080',
          'parent': '150120000080',
          'code2': '1501 20 10',
          'parent2': '1501 20',
          'description': '-- For industrial uses other than manufacture',
          'english_text': 'Pig fat',
          'parent_description': 'Pig fat',
        }, {
          'order': '1971405',
          'level': '5',
          'code': '150210100080',
          'parent': '150210000080',
          'code2': '1502 10 10',
          'parent2': '1502 10',
          'description': '-- For industrial uses other than manufacture',
          'english_text': 'Tallow of bovine animals',
          'parent_description': 'Tallow of bovine animals',
        }, {
          'order': '1971408',
          'level': '5',
          'code': '150290100080',
          'parent': '150290000080',
          'code2': '1502 90 10',
          'parent2': '1502 90',
          'description': '-- For industrial uses other than manufacture',
          'english_text': 'Fats of bovine animals',
          'parent_description': 'Fats of bovine animals',
        }, {
          'order': '1971414',
          'level': '4',
          'code': '150300300080',
          'parent': '150300000080',
          'code2': '1503 00 30',
          'parent2': '1503 00',
          'description': '- Tallow oil for industrial uses other than the manufacture of foodstuffs for human consumption',
          'english_text': 'Tallow oil for industrial uses (excl. for production of foodstuffs and emulsified',
          'parent_description': 'lard oil',
        }, {
          'order': '1971434',
          'level': '5',
          'code': '150710100080',
          'parent': '150710000080',
          'code2': '1507 10 10',
          'parent2': '1507 10',
          'description': '-- For technical or industrial uses other than the manufacture of foodstuffs for human consumption',
          'english_text': 'Crude soya-bean oil',
          'parent_description': 'whether or not degummed',
        }, {
          'order': '1971437',
          'level': '5',
          'code': '150790100080',
          'parent': '150790000080',
          'code2': '1507 90 10',
          'parent2': '1507 90',
          'description': '-- For technical or industrial uses other than the manufacture of foodstuffs for human consumption',
          'english_text': 'Soya-bean oil and its fractions',
          'parent_description': 'Soya-bean oil and its fractions',
        }, {
          'order': '1971441',
          'level': '5',
          'code': '150810100080',
          'parent': '150810000080',
          'code2': '1508 10 10',
          'parent2': '1508 10',
          'description': '-- For technical or industrial uses other than the manufacture of foodstuffs for human consumption',
          'english_text': 'Crude groundnut oil for technical or industrial uses (excl. for production of foodstuffs)',
          'parent_description': 'Crude groundnut oil',
        }, {
          'order': '1971444',
          'level': '5',
          'code': '150890100080',
          'parent': '150890000080',
          'code2': '1508 90 10',
          'parent2': '1508 90',
          'description': '-- For technical or industrial uses other than the manufacture of foodstuffs for human consumption',
          'english_text': 'Groundnut oil and its fractions',
          'parent_description': 'Groundnut oil and its fractions',
        }
      ]
    )
  end
end
