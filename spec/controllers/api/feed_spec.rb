require 'rails_helper'

RSpec.describe Api::FeedController, type: :controller do
  describe 'GET feed controller' do
    it 'responds with an Atom feed' do
      get :index, params: { format: :xml }

      xml_hash = Hash.from_xml(response.body)
      expect(xml_hash).to eq('feed' => {'xmlns' => 'http://www.w3.org/2005/Atom'})
      expect(response.headers['Content-Type']).to eq('application/atom+xml')
    end
  end
end
