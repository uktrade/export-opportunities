require 'rails_helper'

RSpec.describe Api::FeedController, type: :controller do
  describe 'GET feed controller' do
    it 'responds with a 400 if shared_secret is not passed' do
      get :index, params: { format: :xml }
      expect(response.status).to eq(400)
    end

    it 'responds with an Atom feed with the minimum required elements' do
      get :index, params: { format: :xml, shared_secret: '' }

      xml_hash = Hash.from_xml(response.body)
      feed = xml_hash['feed']
      expect(feed['xmlns']).to eq('http://www.w3.org/2005/Atom')
      expect(feed['title']).to match(/\S+/)

      rfc3339_pattern = /^(?<fullyear>\d{4})-(?<month>0[1-9]|1[0-2])-(?<mday>0[1-9]|[12][0-9]|3[01])T(?<hour>[01][0-9]|2[0-3]):(?<minute>[0-5][0-9]):(?<second>[0-5][0-9]|60)(?<secfrac>\.[0-9]+)?(Z|(\+|-)(?<offset_hour>[01][0-9]|2[0-3]):(?<offset_minute>[0-5][0-9]))$/i
      expect(feed['updated']).to match(rfc3339_pattern)

      expect(feed['id']).to match(Rails.env)

      expect(response.headers['Content-Type']).to eq('application/atom+xml')
    end
  end
end
