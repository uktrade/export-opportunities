# coding: utf-8
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
end
