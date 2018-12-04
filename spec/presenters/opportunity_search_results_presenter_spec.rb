# coding: utf-8

require 'rails_helper'

RSpec.describe OpportunitySearchResultsPresenter do
  # Using '=>' syntax to mimic what we get from .yml files.
  # Due to Ruby annoyance doesn't work with nicer syntax.
  CONTENT = { 'some' => 'content',
              'fields' => {
                'countries' => {
                  'question' => 'Countries',
                },
              } }.freeze

  describe '#initialize' do
    it 'initialises a presenter' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.form_path).to eql('/opportunities')
    end
  end

  describe '#field_content' do
    it 'returns the correct content' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters(true))
      field = presenter.field_content('countries')

      expect(field[:options]).to eq([{ label: 'Spain (0)', name: 'Spain', description: nil, value: 'spain', checked: 'true' }])
    end
  end

  describe '#view_all_link' do
    it 'Returns a link when has more opportunities to show' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { total: 2, limit: 1 }, {})

      expect(presenter.view_all_link('some/where')).to include('View all (2)')
    end

    it 'Returns nil when does not have more opportunities to show' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { total: 1, limit: 2 }, {})

      expect(presenter.view_all_link('some/where')).to eql(nil)
    end

    it 'Adds a class name when passed' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { total: 2, limit: 1 }, {})
      class_name = 'with-class'

      expect(presenter.view_all_link('some/where')).to_not include(class_name)
      expect(presenter.view_all_link('some/where', class_name)).to include(class_name)
    end
  end

  describe '#displayed' do
    it 'Returns HTML containing information about results displayed' do
      create(:opportunity, :published, title: 'food')

      Opportunity.__elasticsearch__.refresh_index!

      search = public_search(search_term: 'food')
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})
      message = presenter.displayed

      expect(presenter.displayed).to include('Displaying ')
      expect(has_html?(message)).to be_truthy
    end

    it 'Adds a class name when passed' do
      create(:opportunity, :published, title: 'food')
      search = public_search(search_term: 'food')
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})

      expect(presenter.displayed('class-name')).to include('class-name')
    end
  end

  describe '#found_message' do
    it 'Returns the correct message when more than one results is found' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.found_message(2)).to eql('2 results found')
    end

    it 'Returns the correct message when one results is found' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.found_message(1)).to eql('1 result found')
    end

    it 'Returns the correct message when no results are found' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.found_message(0)).to eql('0 results found')
    end
  end

  describe '#information' do
    it 'Returns result found information message with search term' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { term: 'food', total: 1 }, {})
      message = presenter.information

      expect(message).to include('1 result found for')
      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns result found information message with countries' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { term: 'food', total: 1 }, search_filters)
      message = presenter.information

      expect(message).to include('1 result found')
      expect(message).to include(' in ')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns result found information message with search term and countries' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { term: 'food', total: 1 }, search_filters)
      message = presenter.information

      expect(message).to include('1 result found for')
      expect(message).to include('food')
      expect(message).to include(' in ')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns blank message when empty search is performed' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { total: 10 }, {})

      expect(presenter.information).to eql('')
    end
  end

  describe '#searched_for' do
    it 'Returns plain text message " for [search term]"' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { term: 'food' }, {})

      expect(presenter.searched_for).to eql(' for food')
    end

    it 'Returns HTML markup for message " for [search term]"' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { term: 'food' }, {})
      message = presenter.searched_for(true)

      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns an empty string when searching without a specified term' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.searched_for).to eql('')
    end
  end

  describe '#searched_in' do
    it 'Returns plain text message " in [country]"' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters(true))
      message = presenter.searched_in(true)

      expect(presenter.searched_in).to eql(' in Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns plain text message " in [country] or [country]"' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters)
      message = presenter.searched_in(true)

      expect(presenter.searched_in).to eql(' in Spain or Mexico')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns HTML markup for message " in [country]"' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters(true))
      message = presenter.searched_in(true)

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns HTML markup for message " in [country] or [country]"' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters)
      message = presenter.searched_in(true)

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(message).to include(' or ')
      expect(message).to include('Mexico')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns empty string when no searching without regions or countries' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.searched_in).to eql('')
    end
  end

  describe '#searched_in_with_html' do
    it 'Returns HTML markup for message " in [country]"' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters(true))
      message = presenter.searched_in_with_html

      expect(message).to include(' in ')
      expect(message).to include('Spain')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns HTML markup for message " in [country] or [country]"' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters)
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
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { term: 'food' }, search_filters(true))
      message = presenter.searched_for_with_html

      expect(message).to include(' for ')
      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns an empty string when searching without a specified term' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.searched_for_with_html).to eql('')
    end
  end

  describe '#sort_input_select' do
    it 'Returns object to construct the chosen sort order' do
      content = get_content('opportunities/results')
      presenter = OpportunitySearchResultsPresenter.new(content, { sort_by: 'first_published_at' }, search_filters)
      input = presenter.sort_input_select

      expect(input[:name]).to eql('sort_column_name')
      expect(input[:options][1]).to include(selected: true)
    end
  end

  describe '#selected_filter_list' do
    it 'Returns HTML markup for the selected filters' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters)
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
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})
      params = { 's' => 'food and drink', 'sort_column_name' => 'response_due_on', 'countries' => %w[dominica mexico] }
      headers = { 'CONTENT_TYPE' => 'text/html' }

      get opportunities_path, params: params, headers: headers
      expect(response.status).to eq 200
      expect(presenter.reset_url(request)).to eql('/opportunities?s=food and drink&sort_column_name=response_due_on')
    end
  end

  describe '#subscription' do
    it 'Returns subscription data object' do
      search = public_search(search_term: 'food')
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, search_filters)
      subscription = presenter.subscription

      expect(subscription[:title]).to eql('food in Spain or Mexico')
      expect(subscription[:keywords]).to eql('food')
      expect(subscription[:what]).to eql(' for food')
      expect(subscription[:where]).to eql(' in Spain or Mexico')
    end
  end

  describe '#offer_subscription' do
    it 'Returns false when sectors is not empty' do
      create(:sector, name: 'food and stuff', slug: 'food-and-stuff')
      search = public_search(search_term: 'munchies', sectors: ['food-and-stuff'])
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, search[:filters])

      expect(presenter.offer_subscription).to be_falsey
    end

    it 'Returns false when types is not empty' do
      create(:type, name: 'Strange Thing', slug: 'strange-thing')
      search = public_search(search_term: 'flubber', types: ['strange-thing'])
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})

      expect(presenter.offer_subscription).to be_falsey
    end

    it 'Returns false when values is not empty' do
      create(:value, name: 'Half a penny', slug: 'halfapenny')
      search = public_search(search_term: 'Loads of money', values: ['halfapenny'])
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})

      expect(presenter.offer_subscription).to be_falsey
    end

    it 'Returns false when search_term is empty' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, public_search, {})

      expect(presenter.offer_subscription).to be_falsey
    end

    it 'Returns false when is subscription search' do
      search = public_search(search_term: 'cheap and easy money makers')
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})
      params = { subscription_url: true }

      expect(presenter.offer_subscription(params[:subscription_url].blank?)).to be_falsey
    end

    it 'Returns true when search_term is not empty' do
      search = public_search(search_term: 'cheap and easy money makers')
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})

      expect(presenter.offer_subscription).to be_truthy
    end

    it 'Returns true when countries is not empty' do
      create(:country, name: 'Spain', slug: 'spain')
      search = public_search(countries: %w[spain mexico])
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})

      expect(presenter.offer_subscription).to be_truthy
    end

    it 'Returns true when regions is not empty' do
      create(:country, name: 'Mexico', slug: 'mexico')
      search = public_search(regions: ['south-america'])
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})

      expect(presenter.offer_subscription).to be_truthy
    end

    # Home page passes regions and countries as 'areas[]' param so need to also check this.
    it 'Returns true when areas are passed' do
      create(:country, name: 'Mexico', slug: 'mexico')
      search = public_search(areas: ['south-america'])
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, search, {})

      expect(presenter.offer_subscription).to be_truthy
    end
  end

  describe '#hidden_search_fields' do
    it 'Returns hidden input field to match search term' do
      params = { 's' => 'food and drink', 'something' => 'foo' }
      presenter = OpportunitySearchResultsPresenter.new({}, {}, {})
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to include('food and drink')
      expect(has_html?(hidden_search_fields)).to be_truthy
    end

    it 'Returns hidden input fields to matching multiple areas' do
      params = { 'something' => 'foo', 'sectors' => %w[some-area another-area] }
      presenter = OpportunitySearchResultsPresenter.new({}, {}, {})
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to include('some-area')
      expect(hidden_search_fields).to include('another-area')
      expect(has_html?(hidden_search_fields)).to be_truthy
    end

    it 'Returns hidden input field to matching single area' do
      params = { 'something' => 'foo', 'sectors' => 'some-area' }
      presenter = OpportunitySearchResultsPresenter.new({}, {}, {})
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to include('some-area')
      expect(has_html?(hidden_search_fields)).to be_truthy
    end

    it 'Returns hidden input fields to matching search and areas' do
      params = { 's' => 'food and drink', 'something' => 'foo', 'sectors' => 'some-area' }
      presenter = OpportunitySearchResultsPresenter.new({}, {}, {})
      hidden_search_fields = presenter.hidden_search_fields(params)

      expect(hidden_search_fields).to include('food and drink')
      expect(hidden_search_fields).to include('some-area')
      expect(has_html?(hidden_search_fields)).to be_truthy
    end

    it 'Returns blank string when no relevant params to capture' do
      params = { 'something' => 'foo', 'countries' => 'some-country' }
      presenter = OpportunitySearchResultsPresenter.new({}, {}, {})
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
      presenter = OpportunitySearchResultsPresenter.new({}, {}, field_name: field_data)
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

  describe '#selected_filters' do
    it 'Return a string array of selected filter labels' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters)
      selected = presenter.send(:selected_filters, search_filters)

      expect(selected).to eql(%w[Spain Mexico])
    end

    it 'Return an empty array when no filters selected' do
      filters = search_filters
      filters[:countries][:selected] = []
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, filters)
      selected = presenter.send(:selected_filters, filters)

      expect(selected).to eql([])
    end
  end

  describe '#selected_filters_without' do
    it 'Return a string array of selected filter labels' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters)
      selected = presenter.send(:selected_filters_without, search_filters, [:sectors])

      expect(selected).to eql(%w[Spain Mexico])
    end

    it 'Return an empty array when no filters selected' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters)
      selected = presenter.send(:selected_filters_without, search_filters, [:countries])

      expect(selected).to eql([])
    end
  end

  describe '#filtered_regions' do
    it 'Return a reduced set of regions to match the active countries' do
      helper = TestRegionHelper.new
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters_with_countries_matching_regions)
      regions_after_filtering = presenter.send(:filtered_regions)
      region_slugs = []
      regions_after_filtering.each do |region|
        region_slugs.push region[:slug]
      end

      expect(helper.regions_list.length).to eq(17)
      expect(regions_after_filtering.length).to eq(5)
      expect(region_slugs).to eq(["mediterranean_europe", "south_america", "australia_new_zealand", "south_asia", "south_asia"])
    end

    it 'Return empty region array when filtering matches no regions' do
      helper = TestRegionHelper.new
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters_without_countries_matching_regions)
      regions_after_filtering = presenter.send(:filtered_regions)

      expect(helper.regions_list.length).to eq(17)
      expect(regions_after_filtering.length).to eq(0)
    end
  end

  # Helper functions follow...

  def public_search(params = {}, total = nil)
    params = ActionController::Parameters.new(convert_areas_params_into_regions_and_countries(params))
    filters = SearchFilter.new(params)
    query = Opportunity.public_search(
      search_term: params[:search_term],
      filters: filters,
      sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
    )

    {
      filters: filters,
      results: query.records,
      total: total || query.results.total, # passing an integer for total allows rigging the test result.
      limit: Opportunity.default_per_page,
      term: params[:search_term],
      sort_by: 'relevance',
      subscription: SubscriptionForm.new(query: params),
    }
  end

  # Fake the opportunity_controller workaround to convert areas into countries and regions
  def convert_areas_params_into_regions_and_countries(params)
    if params[:areas].present?
      params[:countries] = [] if params[:countries].blank?
      params[:areas].each do |area|
        if area == 'south-america'
          params[:countries].push 'mexico'
        else
          params[:countries].push area
        end
      end
    end
    params
  end

  def has_html?(message)
    /\<\/\w+\>|\<\w+\s+\w+=/.match(message)
  end

  def country(name, slug = '')
    country = Country.find_by(name: name)
    if country.nil?
      country = if slug.present?
                  create(:country, name: name, slug: slug)
                else
                  create(:country, name: name)
                end
    end
    country
  end

  def search_filters(single_country = false)
    country1 = country('Spain', 'spain')
    country2 = country('Mexico', 'mexico')
    options = [country1, country2]
    selected = [country1.slug, country2.slug]

    if single_country
      options.pop
      selected.pop
    end

    {
      sectors: {
        name: 'sectors[]',
        options: [],
      },

      countries: {
        name: 'countries[]',
        options: options,
        selected: selected,
      },

      regions: {
        name: 'regions[]',
        options: [],
      },
    }
  end

  def search_filters_with_countries_matching_regions
    filters = search_filters
    more_countries = [
      # australia_new_zealand
      create(:country, slug: 'australia'),

      # south_asia
      create(:country, slug: 'bangladesh'),
      create(:country, slug: 'india'),
    ]

    filters[:countries][:options] = filters[:countries][:options].concat(more_countries)
    filters
  end

  def search_filters_without_countries_matching_regions
    filters = search_filters
    no_region_countries = [
      create(:country, slug: 'country_one'),
      create(:country, slug: 'country_two'),
      create(:country, slug: 'country_three'),
    ]

    filters[:countries][:options] = no_region_countries
    filters
  end

  class TestRegionHelper
    include RegionHelper
  end
end
