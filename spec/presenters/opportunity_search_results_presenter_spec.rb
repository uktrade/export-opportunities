# coding: utf-8
require 'rails_helper'

RSpec.describe OpportunitySearchResultsPresenter do
  SOME_CONTENT = { some: 'content' }.freeze

  describe '#initialize' do
    it 'initialises a presenter' do
      presenter = OpportunitySearchResultsPresenter.new(SOME_CONTENT, {}, {})

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
    presenter = OpportunitySearchResultsPresenter.new(SOME_CONTENT, {}, {})
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
    skip("...")
  end

  describe '#displayed' do
    skip("...")
  end

  describe '#found_message' do
    skip("...")
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

