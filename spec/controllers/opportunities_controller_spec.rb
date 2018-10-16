require 'rails_helper'

RSpec.describe OpportunitiesController, :elasticsearch, :commit, type: :controller do
  describe 'GET index' do
    subject(:get_index) { get :index }

    context 'on the new domain' do
      before(:each) do
        expect_any_instance_of(NewDomainConstraint).to receive(:matches?).and_return(true)
      end
      it 'redirects /opportunities to /' do
        skip('TODO: coming up next. new domain will be great.gov/opportunities')
        get_index
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end
    end

    context 'on the old domain' do
      before(:each) do
        expect_any_instance_of(NewDomainConstraint).to receive(:matches?).and_return(false)
      end
      it 'assigns opportunities' do
        skip('TODO: coming up next. old domain will be export.great')
        create(:opportunity, status: 'publish')

        Opportunity.__elasticsearch__.refresh_index!
        get_index
        expect(assigns(:opportunities).count).to eql(1)
      end

      it 'sorts opportunities by their response due date' do
        skip('sometimes fails, need to refresh=wait_for in ES index creation')
        soonest_expiration = create(:opportunity, status: 'publish', response_due_on: 1.month.from_now)
        last_expiration = create(:opportunity, status: 'publish', response_due_on: 3.months.from_now)

        sleep 2
        get_index

        expect(assigns(:opportunities).first.title).to eq(soonest_expiration.title)
        expect(assigns(:opportunities).second.title).to eq(last_expiration.title)
      end
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
