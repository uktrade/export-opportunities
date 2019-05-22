# coding: utf-8
require 'rails_helper'
require 'mock_redis'

RSpec.describe OpportunitiesController, :elasticsearch, :commit, type: :controller do
  include RegionHelper

  describe 'GET #index' do
    
    it "renders" do
      expect(response.status).to eq(200)
    end

    it "provides featured industries" do
      create(:sector, featured: true, featured_order: 1, 
             slug: 'creative-media',     name: 'Creative & Media')
      create(:sector, featured: true, featured_order: 2, 
             slug: 'education-training', name: 'Education & Training')
      create(:sector, featured: true, featured_order: 3, 
             slug: 'food-drink',         name: 'Food and drink')
      create(:sector, featured: true, featured_order: 4, 
             slug: 'oil-gas',            name: 'Oil & Gas')
      create(:sector, featured: true, featured_order: 5, 
             slug: 'security',           name: 'Security')
      create(:sector, featured: true, featured_order: 6, 
             slug: 'retail-and-luxury',  name: 'Retail and luxury')
      
      get :index
      
      industries = assigns(:featured_industries)
      expect(industries.count).to eq 6
    end

    it "provides recent opportunities" do
      10.times do |n|
        create(:opportunity, :published, title: "Title #{n}", slug: n.to_s,
        response_due_on: 1.year.from_now, first_published_at: n.days.ago,
        source: n.even? ? :post : :volume_opps)
      end
      refresh_elasticsearch
      
      get :index
      
      recent = assigns(:recent_opportunities)
      expect(recent.count).to be 5
    end

    it "provides list of countries" do
      create(:country, slug: 'france')
      create(:country, slug: 'germany')
      
      get :index
      
      countries = assigns(:countries)
      expect(countries.any?).to be true
    end

    it "provides list of regions" do
      get :index
      regions = assigns(:regions)
      expect(regions.class).to eq Array
      expect(regions[0]).to eq({ slug: 'australia-new-zealand',
                                 countries: %w[australia fiji new-zealand papua-new-guinea],
                                 name: 'Australia/New Zealand' })
    end

    it "provides statistics about opportunities" do
      mock_redis = MockRedis.new
      mock_redis.set('opps_counters_expiring_soon', '2')
      mock_redis.set('opps_counters_total', '10')
      mock_redis.set('opps_counters_published_recently', '3')
      controller.instance_variable_set(:@redis, mock_redis)

      get :index
      stats = assigns(:opportunities_stats)
      expect(stats[:total]).to be 10
      expect(stats[:expiring_soon]).to be 2
      expect(stats[:published_recently]).to be 3
    end

    context 'provides an XML-based Atom feed' do
      it 'provides the correct MIME type' do
        get :index, params: { format: 'atom' }
        expect(response.content_type).to eq('application/atom+xml')
        expect(response.body).to have_css('feed')
      end

       it 'routes to the feed correctly if you request application/xml' do
        @request.env['HTTP_ACCEPT'] = 'application/xml'
        get :index
        expect(response.content_type).to eq('application/xml')
        expect(response.body).to have_css('feed')
      end

       it 'routes to the feed correctly if you request application/atom+xml' do
        @request.env['HTTP_ACCEPT'] = 'application/atom+xml'
        get :index
        expect(response.content_type).to eq('application/atom+xml')
        expect(response.body).to have_css('feed')
      end

       it "provides a set of opportunities" do
        10.times do |n|
          create(:opportunity, :published, title: "Title #{n}", slug: n.to_s,
          response_due_on: 1.year.from_now, first_published_at: n.day.ago)
        end
        refresh_elasticsearch

         get :index, params: { format: 'atom' }

         opportunities = assigns(:opportunities)
        expect(opportunities.count).to be 10
      end
    end
  end

  describe 'GET #results' do

    before do
      sector     = Sector.create(slug: 'test-sector', name: 'Sector 1')
      @country   = Country.create(slug: 'fiji', name: 'Fiji')
      @country_2 = Country.create(slug: 'barbados', name: 'Barbados')
      type       = Type.create(slug: 'test-type', name: 'Type 1')
      value      = Value.create(slug: 'test-value', name: 'Value 1')
      10.times do |n|
        opportunity = create(:opportunity, :published, title: "Title #{n}", slug: n.to_s,
                             response_due_on: (n + 1).weeks.from_now,
                             first_published_at: (n + 1).weeks.ago)        
        opportunity.sectors   << sector     if n.between?(0,1)
        opportunity.countries << @country   if n.between?(0,2)
        opportunity.countries << @country_2 if n == 3
        opportunity.update(response_due_on: 1.day.from_now) if n == 4
        opportunity.update(first_published_at: 1.day.ago)   if n == 5
      end
      refresh_elasticsearch
    end

    it 'renders' do
      get :results
      data = assigns(:results).instance_variable_get(:@data)
      expect(response.status).to eq(200)
      expect(data[:total]).to eq 10
    end
    it 'filters by search term and provides term' do
      get :results, params: { s: 'Title 0' }
      data = assigns(:results).instance_variable_get(:@data)
      expect(data[:term]).to eq "Title 0"
      expect(data[:total]).to eq 1
    end
    it 'removes non-alphanumeric charecters and words from search' do
      get :results, params: { s: 'Title é 0' }
      data = assigns(:results).instance_variable_get(:@data)
      expect(data[:term]).to eq "Title 0"
      expect(data[:total]).to eq 1
    end
    describe 'filters by search filters' do
      it 'by country' do
        # One country
        get :results, params: { countries: ['fiji'] } 
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:total]).to eq 3
        expect(data[:filter].countries).to eq(
          SearchFilter.new(countries: ['fiji']).countries)
       
        # Multiple countries
        get :results, params: { countries: ['fiji', 'barbados'] }
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:filter].countries).to eq(
          SearchFilter.new(countries: ['fiji', 'barbados']).countries)
        expect(data[:total]).to eq 4
        
        # No valid countries
        get :results, params: { countries: ['invalid-country'] }
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:filter].countries).to eq SearchFilter.new.countries
        expect(data[:total]).to eq 10
      end
      it 'by industry' do
        # One sector
        get :results, params: { sectors: ['test-sector'] } 
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:total]).to eq 2
        expect(data[:filter].sectors).to eq(
          SearchFilter.new(sectors: ['test-sector']).sectors)
        
        # No valid sectors
        get :results, params: { sectors: ['invalid-sector'] }
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:filter].sectors).to eq SearchFilter.new.sectors
        expect(data[:total]).to eq 10
      end
    end
    context 'can sort results and provide @sort_selection' do
      it 'by date_posted' do
        get :results, params: { sort_column_name: 'first_published_at' }
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:results][0].title).to eq "Title 5"
        expect(data[:sort]).to have_attributes(column: 'first_published_at',
                                                        order:  'desc')
      end
      it 'by published soonest' do
        get :results, params: { sort_column_name: 'response_due_on' }
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:results][0].title).to eq "Title 4"
        expect(data[:sort]).to have_attributes(column: 'response_due_on',
                                        order:  'asc')
      end
    end
    describe 'provides @results with data' do
      it 'with the filter' do
        get :results, params: { countries: ['fiji'] } 
        data = assigns(:results).instance_variable_get(:@data)
        filter = data[:filter]
        example_filter = SearchFilter.new(countries: ['fiji'])
        expect(filter.countries).to eq(example_filter.countries)
      end
      it 'with the term' do
        get :results, params: { s: 'Title 0' }
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:term]).to eq "Title 0"
      end
      it 'with the sort order' do
        get :results, params: { sort_column_name: 'response_due_on' }
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:sort]).to have_attributes(column: 'response_due_on', order: 'asc')
      end
      it 'with the results' do
        get :results
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:results].count).to eq 10
      end
      it 'with the total' do
        get :results
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:total]).to eq 10
      end
      it 'with the max total' do
        get :results
        data = assigns(:results).instance_variable_get(:@data)
        expect(data[:total_without_limit]).to eq 10
      end
      describe 'provides a valid subscription form object' do
        it "includes the search term" do
          get :results, params: { s: 'Title 0' }
          subscription = assigns(:subscription)
          expect(subscription).to eq({
                                       title: "Title 0",
                                       keywords: "Title 0",
                                       countries: [],
                                       what: " for Title 0",
                                       where: "",
                                     })
        end
      end
      describe 'provides the filter_data' do
        it 'with sectors' do
          get :results, params: { sectors: ['test-sector'] } 
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:sectors]).to eq(
            {
              'name': 'sectors[]',
              'options': Sector.order(:name),
              'selected': ['test-sector'],
            }
          )
          get :results, params: { sectors: ['invalid-sector'] }
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:sectors]).to eq(
            {
              'name': 'sectors[]',
              'options': Sector.order(:name),
              'selected': [],
            }
          )
        end
        it 'with relevant countries shown and valid countries selected' do
          get :results, params: { countries: ['fiji'] } 
          @country.update_attribute(:opportunity_count, 3)
          @country_2.update_attribute(:opportunity_count, 1)
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:countries]).to eq(
            {
              'name': 'countries[]',
              'options': [@country],
              'selected': ['fiji'],
            }
          )
          # Note: for invalid search, search is blank therefore more results returned
          #       resulting in more countries shown in options
          get :results, params: { countries: ['invalid-country'] }
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:countries]).to eq(
            {
              'name': 'countries[]',
              'options': [@country_2, @country],
              'selected': [],
            }
          )
        end
        it 'with relevant regions shown and valid regions selected' do
          # Without selection
          get :results, params: { countries: ['fiji'] } 
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:regions]).to eq(
            {
              'name': 'regions[]',
              'options': [region_by_country_slug('fiji')],
              'selected': [],
            }
          )
          # With selection
          get :results, params: { countries: ['fiji'], regions: ['australia-new-zealand'] } 
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:regions]).to eq(
            {
              'name': 'regions[]',
              'options': [region_by_country_slug('fiji')],
              'selected': ['australia-new-zealand'],
            }
          )
          # Invalid country
          get :results, params: { countries: ['invalid-country'] } 
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:regions]).to eq(
            {
              'name': 'regions[]',
              'options': [region_by_country_slug('barbados'),
                          region_by_country_slug('fiji')],
              'selected': [],
            }
          )
        end
        it 'with sources' do
          options = Opportunity.sources.keys.map{|k| k == 'buyer' ? nil : { slug: k } }.compact
          get :results, params: { sources: ['post'] } 
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:sources]).to eq(
            {
              'name': 'sources[]',
              'options': options,
              'selected': ['post'],
            }
          )
          get :results, params: { sources: ['invalid-source'] }
          filter_data = assigns(:results).instance_variable_get(:@filter_data)
          expect(filter_data[:sources]).to eq(
            {
              'name': 'sources[]',
              'options': options,
              'selected': [],
            }
          )
        end
      end
    end
  end

  describe 'GET :id' do
    it 'assigns opportunities' do
      opportunity = create(:opportunity, status: :publish)
      get :show, params: { id: opportunity.id }
      expect(assigns(:opportunity)).to eq(opportunity)
    end

    it '404s if opportunity is not found' do
      get :show, params: { id: 'not-even-close-to-a-thing' }
      expect(response).to have_http_status(:not_found)
    end
  end
end
