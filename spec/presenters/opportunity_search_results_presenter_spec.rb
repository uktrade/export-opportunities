# coding: utf-8
require 'rails_helper'

RSpec.describe OpportunitySearchResultsPresenter do
  CONTENT = { some: 'content' }.freeze

  describe '#initialize' do
    it 'initialises a presenter' do
      presenter = OpportunitySearchResultsPresenter.new(CONTENT, {}, {})

      expect(presenter.form_path).to eql('/opportunities')
    end
  end

  describe '#field_content' do
    it 'returns the correct content' do
      content = { fields: { countries: { question: 'Countries' } } }
      presenter = OpportunitySearchResultsPresenter.new(content, {}, search_filters)
      field = presenter.field_content('countries')
      
      expect(field['options']).to include({:label=>"Barbados (0)", :value=>"barbados"})
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
      expect(presenter.displayed).to include('Displaying items')
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
    skip("...")
  end

  describe '#searched_for' do
    skip("...")
  end

  describe '#searched_in' do
    skip("...")
  end

  describe '#searched_in_html' do
    skip("...")
  end

  describe '#sort_input_select' do
    skip("...")
  end

  describe '#selected_filter_list' do
    skip("...")
  end

  describe '#reset_url' do
    skip("...")
  end

  describe '#subscription' do
    skip("...")
  end

  def search_filters
    {
      sectors:  {
        name: 'sectors[]',
        options: [],
      },
 
      countries: {
        name: 'countries[]',
        options: [
          Country.new({
            id: 105,
            slug: 'barbados',
            name: 'Barbados',
            exporting_guide_path: '/government/publications/exporting-to-barbados',
            region_id: nil,
            published_target: nil,
            responses_target: nil,
          }),
          Country.new({
            id: 4,
            slug: 'dominican-republic',
            name: 'Dominican Republic',
            exporting_guide_path: nil,
            region_id: nil,
            published_target: nil,
            responses_target: nil,
          }),
          Country.new({
            id: 55,
            slug: 'jamaica',
            name: 'Jamaica',
            exporting_guide_path: '/government/publications/exporting-to-jamaica',
            region_id: nil,
            published_target: nil,
            responses_target: nil,
          }),
          Country.new({
            id: 94,
            slug: 'paraguay',
            name: 'Paraguay',
            exporting_guide_path: nil,
            region_id: nil,
            published_target: nil,
            responses_target: nil
          })
        ],
        selected: []
      },

      regions: {
        name: 'regions[]',
        options: []
      }
    }
  end

end

