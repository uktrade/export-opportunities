# coding: utf-8

require 'rails_helper'

RSpec.describe OpportunitySearchResultsPresenter do
  include RegionHelper
  let(:content) { get_content('opportunities/results') }
  let(:region_helper) { TestRegionHelper.new }

  before(:each) do
    countries(%w[spain mexico])
  end

  describe '#initialize' do
    it 'initialises a presenter' do
      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.term).to eql('food')
    end
  end

  describe '#field_content' do
    it 'returns the correct content' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      field = presenter.field_content('countries')
      # { label:'Mexico (0)', name:'Mexico', description:nil, value:'mexico', checked:'true' }
      # { label:'Spain (0)', name:'Spain', description:nil, value:'spain', checked:'true' }

      field[:options].each do |option|
        expect(option[:label]).to eq('Mexico (0)').or eq('Spain (0)')
        expect(option[:name]).to eq('Mexico').or eq('Spain')
        expect(option[:description]).to be_nil
        expect(option[:value]).to eq('mexico').or eq('spain')
        expect(option[:checked]).to be_truthy
      end
    end
  end

  describe '#view_all_link' do
    it 'Returns a link when has more opportunities to show' do
      params = { s: 'food' }
      results = search(params)
      results[:total] = 15
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      expect(presenter.view_all_link('some/where')).to include('View all (15)')
    end

    it 'Returns nil when does not have more opportunities to show' do
      params = { s: 'food' }
      results = search(params)
      results[:total] = 1
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      field = presenter.field_content('countries')

      expect(presenter.view_all_link('some/where')).to eql(nil)
    end

    it 'Adds a class name when passed' do
      params = { s: 'food' }
      results = search(params)
      results[:total] = 15
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      class_name = 'with-class'

      expect(presenter.view_all_link('some/where')).to_not include(class_name)
      expect(presenter.view_all_link('some/where', class_name)).to include(class_name)
    end
  end

  describe '#displayed' do
    it 'Returns HTML containing information about results displayed' do
      create(:opportunity, :published, title: 'food')

      Opportunity.__elasticsearch__.refresh_index!

      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.displayed

      expect(presenter.displayed).to include('Displaying ')
      expect(has_html?(message)).to be_truthy
    end

    it 'Adds a class name when passed' do
      create(:opportunity, :published, title: 'food')
      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.displayed('class-name')).to include('class-name')
    end
  end

  describe '#found_message' do
    # faking found and returned result numbers for tests

    it 'Returns the correct message when more than one results is found' do
      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.found_message).to eql('2 results found')
    end

    it 'Returns the correct message when one results is found' do
      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.found_message).to eql('1 result found')
    end

    it 'Returns the correct message when no results are found' do
      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.found_message).to eql('0 results found')
    end
  end

  describe '#max_results_exceeded_message' do
    # faking found and returned result numbers for tests

    it 'Returns custom message when results exceed the defined limit' do
      url_params = { s: 'food' }
      total_found = 2000
      total_returned = 500
      search = public_search(url_params, total_returned, total_found)
      presenter = OpportunitySearchResultsPresenter.new(content, search)
      expect(presenter.max_results_exceeded_message).to eql(presenter.content_with_inclusion('max_results_exceeded', [total_returned, total_found]))
    end
  end

  describe '#information' do
    # Passing fake found and returned result numbers to public_search to control tests

    it 'Returns max_results_exceeded_message when results exceed the defined limit' do
      url_params = { s: 'food' }
      total_found = 2000
      total_returned = 500
      search = public_search(url_params, total_returned, total_found)
      presenter = OpportunitySearchResultsPresenter.new(content, search)
      expect(presenter.information).to eql(presenter.content_with_inclusion('max_results_exceeded', [total_returned, total_found]))
    end

    it 'Returns result found information message with search term' do
      params = { s: 'food' }
      results = search(params)
      results[:total] = 1
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.information

      expect(message).to include('1 result found for')
      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns result found information message with countries' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      results[:total] = 1
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.information

      expect(message).to include('1 result found')
      expect(message).to include(' in ')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns result found information message with search term and countries' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      results[:total] = 1
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.information

      expect(message).to include('1 result found for')
      expect(message).to include('food')
      expect(message).to include(' in ')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns blank message when empty search is performed' do
      params = { s: '' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.information).to eql('')
    end
  end

  describe '#searched_for' do
    it 'Returns plain text message " for [search term]"' do
      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.searched_for).to eql(' for food')
    end

    it 'Returns HTML markup for message " for [search term]"' do
      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.searched_for(true)

      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns an empty string when searching without a specified term' do
      params = { s: '' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.searched_for).to eql('')
    end
  end

  describe '#searched_in' do
    it 'Returns plain text message " in [country]"' do
      params = { s: 'food', countries: %w[spain] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.searched_in(true)

      expect(presenter.searched_in).to eql(' in Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns plain text message " in [country] or [country]"' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.searched_in(true)
      output = [' in Spain or Mexico', ' in Mexico or Spain']

      expect(output).to include(presenter.searched_in)
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns HTML markup for message " in [country]"' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.searched_in(true)

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns HTML markup for message " in [country] or [country]"' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.searched_in(true)

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(message).to include(' or ')
      expect(message).to include('Mexico')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns empty string when no searching without regions or countries' do
      params = {}
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.searched_in).to eql('')
    end

    it 'Returns countries as a region name when a full set is matched' do
      slugs = %w[armenia azerbaijan georgia kazakhstan mongolia russia tajikistan turkey ukraine uzbekistan]
      countries(slugs)
      params = { s: 'food', countries: slugs }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      searched_in_without_matched_regions = presenter.searched_in
      names = searched_in_without_matched_regions.gsub(/\s+(or|in)\s+/, '|').split('|').drop(1) # first is empty

      # First run it with countries that won't match a full region
      expect(names.length).to eq(10)
      expect(names.join(' ')).to eq('Armenia Azerbaijan Georgia Kazakhstan Mongolia Russia Tajikistan Turkey Ukraine Uzbekistan')

      # Now add some countries that should match regions
      mediterranean_europe = %w[cyprus greece israel italy portugal spain]
      north_east_asia = %w[taiwan south-korea japan]
      countries(mediterranean_europe)
      countries(north_east_asia)
      params = { s: 'food', countries: slugs.concat(mediterranean_europe, north_east_asia) }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      searched_in_with_matched_regions = presenter.searched_in
      names = searched_in_with_matched_regions.gsub(/\s+(or|in)\s+/, '|').split('|').drop(1) # first is empty

      expect(names.length).to eq(12)
      expect(names.join(' ')).to eq('Mediterranean Europe North East Asia Armenia Azerbaijan Georgia Kazakhstan Mongolia Russia Tajikistan Turkey Ukraine Uzbekistan')
    end
  end

  describe '#searched_in_with_html' do
    it 'Returns HTML markup for message " in [country]"' do
      params = { s: 'food', countries: %w[spain] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.searched_in_with_html

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns HTML markup for message " in [country] or [country]"' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.searched_in_with_html

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(message).to include(' or ')
      expect(message).to include('Mexico')
      expect(has_html?(message)).to be_truthy
    end
  end

  describe '#searched_for_with_html' do
    it 'Returns HTML markup for message " for [search term]"' do
      params = { s: 'food' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      message = presenter.searched_for_with_html

      expect(message).to include(' for ')
      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns an empty string when searching without a specified term' do
      params = {}
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.searched_for_with_html).to eql('')
    end
  end

  describe '#sort_input_select' do
    it 'Returns object to construct the chosen sort order' do
      params = { s: 'food', sort_column_name: 'first_published_at' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      input = presenter.sort_input_select

      expect(input[:name]).to eql('sort_column_name')
      expect(input[:options][1]).to include(selected: true)
    end
  end

  describe '#selected_filter_list' do
    it 'Returns HTML markup for the selected filters' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      title = 'this is a title'
      selected_filters = presenter.selected_filter_list(title)

      expect(has_html?(selected_filters)).to be_truthy
      expect(selected_filters).to include(title)
      expect(selected_filters).to include('Mexico')
      expect(selected_filters).to include('Spain')
      expect(selected_filters).to_not include('Dominica')
    end
  end

  describe '#reset_url', type: :request do
    it 'Returns url and params, without filters, as a string' do
      params = {}
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      params = { 's' => 'food and drink', 'sort_column_name' => 'response_due_on', 'countries' => %w[dominica mexico] }
      headers = { 'CONTENT_TYPE' => 'text/html' }

      get opportunities_path, params: params, headers: headers
      expect(response.status).to eq 200
      expect(presenter.reset_url(request)).to eql('/opportunities?s=food and drink&sort_column_name=response_due_on')
    end
  end

  describe '#subscription' do
    it 'Returns subscription data object' do
      params = { s: 'food', countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      subscription = presenter.subscription

      expect(subscription[:title]).to eq('food in Mexico or Spain').or eql('food in Spain or Mexico')
      expect(subscription[:keywords]).to eq('food')
      expect(subscription[:what]).to eq(' for food')
      expect(subscription[:where]).to eq(' in Mexico or Spain').or eq(' in Spain or Mexico')
    end
  end

  describe '#offer_subscription' do
    it 'Returns false when sectors is not empty' do
      create(:sector, name: 'food and stuff', slug: 'food-and-stuff')
      params = { s: 'munchies', sectors: ['food-and-stuff'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription).to be_falsey
    end

    it 'Returns false when types is not empty' do
      create(:type, name: 'Strange Thing', slug: 'strange-thing')
      params = { s: 'flubber', types: ['strange-thing'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription).to be_falsey
    end

    it 'Returns false when values is not empty' do
      create(:value, name: 'Half a penny', slug: 'halfapenny')
      params = { s: 'Loads of money', values: ['halfapenny'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription).to be_falsey
    end

    it 'Returns false when search_term is empty' do
      params = { s: '' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription).to be_falsey
    end

    it 'Returns false when is subscription search' do
      not_subscription_url = false
      params = { s: 'cheap and easy money makers', subscription_url: not_subscription_url }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription(not_subscription_url)).to be_falsey
    end

    it 'Returns true when search_term is not empty' do
      params = { s: 'cheap and easy money makers' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription).to be_truthy
    end

    it 'Returns true when countries is not empty' do
      params = { countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription).to be_truthy
    end

    it 'Returns true when regions is not empty' do
      params = { regions: %w[south-america] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription).to be_truthy
    end

    # Home page passes regions and countries as 'areas[]' param so need to also check this.
    it 'Returns true when areas are passed' do
      params = { areas: %w[south-america] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))

      expect(presenter.offer_subscription).to be_truthy
    end
  end

  describe '#hidden_search_fields' do
    it 'Returns hidden input field to match search term' do
      params = { s: 'food and drink', something: 'foo' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to include('food and drink')
      expect(has_html?(hidden_search_fields)).to be_truthy
    end

    it 'Returns hidden input fields to matching multiple areas' do
      params = { something: 'foo', sectors: %w[some-area another-area] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to include('some-area')
      expect(hidden_search_fields).to include('another-area')
      expect(has_html?(hidden_search_fields)).to be_truthy
    end

    it 'Returns hidden input field to matching single area' do
      params = { something: 'foo', sectors: 'some-area' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to include('some-area')
      expect(has_html?(hidden_search_fields)).to be_truthy
    end

    it 'Returns hidden input fields to matching search and areas' do
      params = { s: 'food and drink', something: 'foo', sectors: 'some-area' }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to include('food and drink')
      expect(hidden_search_fields).to include('some-area')
      expect(has_html?(hidden_search_fields)).to be_truthy
    end

    it 'Returns blank string when no relevant params to capture' do
      params = { something: 'foo', countries: %w[some-country] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to eq('')
    end
  end

  describe '#format_filter_checkboxes' do
    it 'Returns a field hash created from a mix of content and data' do
      field_content = { 'question' => 'something',
                        'options' => [{ 'label' => 'foo', 'description' => 'label help' }],
                        'description' => 'question help' }
      field_data = { name: 'info', options: [{ slug: 'boo' }], selected: [] }
      presenter = OpportunitySearchResultsPresenter.new(content, { filter_data: { field_name: field_data } }, subscr_form(search({})))

      checkboxes = presenter.send(:format_filter_checkboxes, field_content, :field_name)

      expect(checkboxes[:name]).to eq('info')
      expect(checkboxes[:options][0][:label]).to eq('foo')
      expect(checkboxes[:options][0][:name]).to eq('foo')
      expect(checkboxes[:options][0][:description]).to eq('label help')
      expect(checkboxes[:options][0][:value]).to eq('boo')
      expect(checkboxes[:question]).to eq('something')
      expect(checkboxes[:description]).to eq('question help')
    end
  end

  describe '#selected_filter_option_names' do
    it 'Return a string array of selected filter labels' do
      params = { countries: %w[spain mexico] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      selected = presenter.send(:selected_filter_option_names)

      expect(selected).to eq(%w[Mexico Spain]).or eq(%w[Spain Mexico])
    end

    it 'Return an empty array when no filters selected' do
      params = {}
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      selected = presenter.send(:selected_filter_option_names)

      expect(selected).to eql([])
    end
  end

  describe 'builds a filter_data hash' do
    before do
      @country   = Country.create(slug: 'fiji', name: 'Fiji')
      @country_2 = Country.create(slug: 'barbados', name: 'Barbados')
      10.times do |n|
        opportunity = create(:opportunity, :published, title: "Title #{n}", slug: n.to_s,
                             response_due_on: (n + 1).weeks.from_now,
                             first_published_at: (n + 1).weeks.ago)        
        opportunity.countries << @country   if n.between?(0,2)
        opportunity.countries << @country_2 if n == 3
      end
      refresh_elasticsearch
    end

    it 'with sectors' do
      create(:sector, name: 'food and stuff', slug: 'food-and-stuff')
      params = { s: 'munchies', sectors: ['food-and-stuff'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      filter_data = presenter.instance_variable_get(:@filter_data)
      expect(filter_data[:sectors]).to eq(
        {
          'name': 'sectors[]',
          'options': Sector.order(:name),
          'selected': ['food-and-stuff'],
        }
      )
      params = { s: 'munchies', sectors: ['invalid-sector'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      filter_data = presenter.instance_variable_get(:@filter_data)
      expect(filter_data[:sectors]).to eq(
        {
          'name': 'sectors[]',
          'options': Sector.order(:name),
          'selected': [],
        }
      )
    end
    it 'with relevant countries shown and valid countries selected' do
      params = { countries: ['fiji'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      filter_data = presenter.instance_variable_get(:@filter_data)

      expect(filter_data[:countries]).to eq(
        {
          'name': 'countries[]',
          'options': [@country],
          'selected': ['fiji'],
        }
      )
      # Note: for invalid search, search is blank therefore more results returned
      #       resulting in more countries shown in options
      params = { countries: ['invalid-country'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      filter_data = presenter.instance_variable_get(:@filter_data)

      expect(filter_data[:countries]).to eq(
        {
          'name': 'countries[]',
          'options': [@country_2, @country],
          'selected': [],
        }
      )
    end
    it 'with relevant regions shown and valid regions selected' do
      # Without regions selection
      params = { countries: ['fiji'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      filter_data = presenter.instance_variable_get(:@filter_data)

      expect(filter_data[:regions]).to eq(
        {
          'name': 'regions[]',
          'options': [region_by_country_slug('fiji')],
          'selected': [],
        }
      )
      # # With regions selection
      # params = { countries: ['fiji'], regions: ['australia-new-zealand'] }
      # results = search(params)
      # presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      # filter_data = presenter.instance_variable_get(:@filter_data)

      # expect(filter_data[:regions]).to eq(
      #   {
      #     'name': 'regions[]',
      #     'options': [region_by_country_slug('fiji')],
      #     'selected': ['australia-new-zealand'],
      #   }
      # )
      # # Invalid country - shows all options
      # params = { countries: ['invalid-country'] }
      # results = search(params)
      # presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      # filter_data = presenter.instance_variable_get(:@filter_data)

      # expect(filter_data[:regions]).to eq(
      #   {
      #     'name': 'regions[]',
      #     'options': [region_by_country_slug('barbados'),
      #                 region_by_country_slug('fiji')],
      #     'selected': [],
      #   }
      # )
    end
    it 'with sources' do
      options = Opportunity.sources.keys.map{|k| k == 'buyer' ? nil : { slug: k } }.compact
      params = { sources: ['post'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      filter_data = presenter.instance_variable_get(:@filter_data)

      expect(filter_data[:sources]).to eq(
        {
          'name': 'sources[]',
          'options': options,
          'selected': ['post'],
        }
      )
      params = { sources: ['invalid-source'] }
      results = search(params)
      presenter = OpportunitySearchResultsPresenter.new(content, results, subscr_form(results))
      filter_data = presenter.instance_variable_get(:@filter_data)

      expect(filter_data[:sources]).to eq(
        {
          'name': 'sources[]',
          'options': options,
          'selected': [],
        }
      )
    end
  end

  # Helper functions follow...

  def search(params, total=nil)
    params = region_helper.region_and_country_param_conversion(params)
    Search.new(params).run
  end

  def subscr_form(results)
    OpportunitiesController.new.send(:subscription_form, results)
  end

  def has_html?(message)
    %r{\<\/\w+\>|\<\w+\s+\w+=}.match(message)
  end

  def countries(slugs)
    countries = []
    slugs.each do |slug|
      country = Country.find_by(slug: slug)
      country = create(:country, name: to_words(slug), slug: slug) if country.nil?
      countries.push(country)
    end
    countries
  end

  def to_words(slug)
    arr = slug.split('-')
    arr.each_with_index { |word, index| arr[index] = word.capitalize }
    arr.join(' ')
  end

  class TestRegionHelper
    include RegionHelper
  end

end
