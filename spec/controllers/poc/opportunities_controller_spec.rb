require 'rails_helper'

describe Poc::OpportunitiesController, :elasticsearch, :commit, type: :controller do
  describe 'GET index' do
    subject(:get_index) { get :index }

    context 'provides an XML-based Atom feed' do
      it 'provides the correct MIME type' do
        skip('TODO: implement Atom feed for POC opportunities')
        get :index, params: {format: 'atom'}
        expect(response.content_type).to eq('application/atom+xml')
        expect(response.body).to have_css('feed')
      end

      it 'routes to the feed correctly if you request application/xml' do
        skip('TODO: implement Atom feed for POC opportunities')
        @request.env['HTTP_ACCEPT'] = 'application/xml'
        get :index
        expect(response.content_type).to eq('application/xml')
        expect(response.body).to have_css('feed')
      end

      it 'routes to the feed correctly if you request application/atom+xml' do
        skip('TODO: implement Atom feed for POC opportunities')
        @request.env['HTTP_ACCEPT'] = 'application/atom+xml'
        get :index
        expect(response.content_type).to eq('application/atom+xml')
        expect(response.body).to have_css('feed')
      end
    end
  end

  describe 'GET :id' do
    it 'assigns opportunities' do
      opportunity = create(:opportunity, status: :publish)
      get :show, params: {id: opportunity.id}
      expect(assigns(:opportunity)).to eq(opportunity)
    end

    it '404s if opportunity is not found' do
      get :show, params: {id: 'not-even-close-to-a-thing'}
      expect(response).to have_http_status(:not_found)
    end
  end
end
