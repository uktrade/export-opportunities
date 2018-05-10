require 'json'
require 'rails_helper'

rfc3339_pattern = /^(?<fullyear>\d{4})-(?<month>0[1-9]|1[0-2])-(?<mday>0[1-9]|[12][0-9]|3[01])T(?<hour>[01][0-9]|2[0-3]):(?<minute>[0-5][0-9]):(?<second>[0-5][0-9]|60)(?<secfrac>\.[0-9]+)?(Z|(\+|-)(?<offset_hour>[01][0-9]|2[0-3]):(?<offset_minute>[0-5][0-9]))$/i

RSpec.describe Api::FeedController, type: :controller do
  describe 'GET feed controller' do
    it 'responds with a 400 if shared_secret is not passed' do
      get :index, params: { format: :xml }
      expect(response.status).to eq(400)
    end

    it 'responds with a 403 if shared_secret passed, but is incorrect' do
      get :index, params: { format: :xml, shared_secret: 'not-the-right-secret' }
      expect(response.status).to eq(403)
    end

    it 'responds with an Atom feed with the minimum required elements' do
      get :index, params: { format: :xml, shared_secret: 'secret' }

      xml_hash = Hash.from_xml(response.body)
      feed = xml_hash['feed']
      expect(feed['xmlns']).to eq('http://www.w3.org/2005/Atom')
      expect(feed['title']).to match(/\S+/)
      expect(feed['updated']).to match(rfc3339_pattern)

      expect(feed['id']).to match(Rails.env)

      expect(response.headers['Content-Type']).to eq('application/atom+xml')
    end

    it 'does not have any entry elements by default' do
      get :index, params: { format: :xml, shared_secret: 'secret' }

      xml_hash = Hash.from_xml(response.body)
      feed = xml_hash['feed']

      expect(feed.key?('entry')).to eq(false)
    end

    it 'does not have any entry elements if an enquiry made without a company number' do
      create(:enquiry, company_house_number: nil)

      get :index, params: { format: :xml, shared_secret: 'secret' }

      xml_hash = Hash.from_xml(response.body)
      feed = xml_hash['feed']

      expect(feed.key?('entry')).to eq(false)
    end

    it 'does not have any entry elements if an enquiry made without a blank company house number' do
      create(:enquiry, company_house_number: '')

      get :index, params: { format: :xml, shared_secret: 'secret' }

      xml_hash = Hash.from_xml(response.body)
      feed = xml_hash['feed']

      expect(feed.key?('entry')).to eq(false)
    end

    it 'has a single entry element if a company has been made with a company house number' do
      enquiry = nil
      Timecop.freeze(Time.utc(2008, 9, 1, 12, 1, 2)) do
        enquiry = create(:enquiry, company_house_number: '123')
      end

      get :index, params: { format: :xml, shared_secret: 'secret' }
      xml_hash = Hash.from_xml(response.body)
      feed = xml_hash['feed']

      expect(feed.key?('entry')).to eq(true)
      expect(feed['entry']['id']).to match(/-#{enquiry.id}/)
      expect(feed['entry']['updated']).to match(rfc3339_pattern)
      expect(feed['entry']['updated']).to eq('2008-09-01T12:01:02+00:00')
      expect(feed['entry']['title']).to match(/\S+/)

      elastic_search_bulk =  JSON.parse(feed['entry']['elastic_search_bulk'])
      expect(elastic_search_bulk['action_and_metadata']['index']['_index']).to eq('company_timeline')
      expect(elastic_search_bulk['action_and_metadata']['index']['_type']).to eq('_doc')
      expect(elastic_search_bulk['action_and_metadata']['index']['_id']).to eq("export-oportunity-enquiry-made-#{enquiry.id}")

      expect(elastic_search_bulk['source']['date']).to eq('2008-09-01T12:01:02+00:00')
      expect(elastic_search_bulk['source']['activity']).to eq('export-oportunity-enquiry-made')
      expect(elastic_search_bulk['source']['company_house_number']).to eq('123')
    end
  end
end
