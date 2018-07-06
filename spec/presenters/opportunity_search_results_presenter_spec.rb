# coding: utf-8
require 'rails_helper'

RSpec.describe OpportunitySearchResultsPresenter do
  CONTENT = { some: 'content', 
              fields: {
                countries: {
                  question: 'Countries'
                }
              }
            }.freeze

  describe '#initialize' do
    it 'initialises a presenter' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.form_path).to eql('/opportunities')
    end
  end

  describe '#field_content' do
    it 'returns the correct content' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, search_filters)
      field = presenter.field_content('countries')
      
      expect(field['options']).to include({:label => "Mexico (0)", :value => "mexico", :checked => "true"})
    end
  end

  describe '#title_with_country' do
    presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})
    title = 'An Export Opportunity'

    it 'Returns unaltered opportunity.title when from Post' do
      countries = [ create(:country, { name: 'Spain' }), create(:country, { name: 'France' }) ]
      opportunity = create(:opportunity, { title: title, source: :post, countries: countries })

      expect(presenter.title_with_country(opportunity)).to eql(opportunity.title)
      expect(presenter.title_with_country(opportunity)).to eql(title)
    end

    it 'Returns "Multi Country - [opportunity.title]" when has multiple countries' do
      countries = [ create(:country, { name: 'Spain' }), create(:country, { name: 'France' }) ]
      opportunity = create(:opportunity, { title: title, source: :volume_opps, countries: countries })

      expect(presenter.title_with_country(opportunity)).to eql("Multi Country - #{title}")
    end

     it 'Returns "[country] - [opportunity.title]" when has single country.' do
       countries = [ create(:country, { name: 'Spain' }) ]
       opportunity = create(:opportunity, { title: title, source: :volume_opps, countries: countries })

       expect(presenter.title_with_country(opportunity)).to eql("Spain - #{title}")
     end
  end

  describe '#view_all_link' do
    it 'Returns a link when has more opportunites to show' do
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
    it 'Returns a <p> element containing information about results displayed' do
      create(:opportunity, :published, { title: 'food' })
      query = Opportunity.public_search(
        search_term: 'food',
        filters: SearchFilter.new({s: 'food'}),
        sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
      )

      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { results: query.results }, {})
    
      expect(presenter.displayed).to start_with('<p')

      expect(presenter.displayed).to include('Displaying <b>1</b> item')
    end

    it 'Adds a class name when passed' do
      create(:opportunity, :published, { title: 'food' })
      query = Opportunity.public_search(
        search_term: 'food',
        filters: SearchFilter.new({s: 'food'}),
        sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
      )

      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { results: query.results }, {})

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
    it 'Returns result found information message' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { total: 1 }, {})
      message = presenter.information

      expect(message).to eql('1 result found')
      expect(has_html?(message)).to be_falsey
    end

    it 'Returns result found information message with search term' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { term: 'food', total: 1 }, {})
      message = presenter.information

      expect(message).to include('1 result found for')
      expect(message).to include('food')
      expect(has_html?(message)).to be_truthy
    end

    it 'Returns result found information message with countries' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { total: 1 }, search_filters)
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
  end

  describe '#searched_for' do
    it 'Returns plain text message " for [search term]"' do
      create(:opportunity, :published, { title: 'food' })
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { term: 'food' }, {})

      expect(presenter.searched_for).to eql(' for food')
    end

    it 'Returns HTML markup for message " for [search term]"' do
      create(:opportunity, :published, { title: 'food' })
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

  describe '#sort_input_select' do
    it 'Returns object to construct the chosen sort order' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { sort_by: 'first_published_at' }, search_filters)
      input = presenter.sort_input_select

      expect(input[:name]).to eql('sort_column_name')
      expect(input[:options][1]).to include(selected: true)
    end
  end

  describe '#selected_filter_list' do
    it 'returns the selected filter names' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})
      selected_filters = presenter.selected_filter_list(search_filters)

      expect(selected_filters).to include('Mexico')
      expect(selected_filters).to include('Spain')
      expect(selected_filters).to_not include('Dominica')
    end
  end

  describe '#reset_url', type: :request do
    it 'Returns url and params, without filters, as a string' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})
      params = {"s"=>"food and drink", "sort_column_name"=>"response_due_on", "countries"=>["dominica", "mexico"]}
      headers = { "CONTENT_TYPE" => "text/html" }

      get opportunities_path, params: params, headers: headers
      expect(response.status).to eq 200
      expect(presenter.reset_url(request)).to eql('/opportunities?s=food and drink&sort_column_name=response_due_on')
    end
  end

  describe '#subscription' do
    it 'Returns subscription data object' do
      filters = search_filters
      form = SubscriptionForm.new(
        query: {
          search_term: 'food',
          sectors: [],
          types: [],
          countries: filters[:countries],
          values: [],
        }
      )
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, { subscription: form, term: 'food' }, filters)
      subscription = presenter.subscription

      expect(subscription[:form]).to eql(form)
      expect(subscription[:what]).to eql(' for food')
      expect(subscription[:where]).to eql(' in Spain or Mexico')
    end
  end

  def has_html?(message)
    /\<\/\w+\>/.match(message)
  end

  def country(name, slug='')
    country = Country.find_by(name: name)
    if country.nil?
      if slug.length > 0
        country = create(:country, { name: name, slug: slug })
      else
        country = create(:country, { name: name })
      end
    end
    country
  end

  def search_filters(single_country = false)
    country_1 = country('Spain', 'spain')
    country_2 = country('Mexico', 'mexico')
    options = [ country_1, country_2 ]
    selected = [ country_1.slug, country_2.slug ]

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
        selected: selected
      },

      regions: {
        name: 'regions[]',
        options: []
      }
    }
  end

end

