require 'rails_helper'

describe Admin::EnquiryResponsesController, type: :controller do
  # let(:country) { create(:country) }
  # let(:sector) { create(:sector) }
  # let(:type) { create(:type) }
  # let(:value) { create(:value) }
  # let(:service_provider) { create(:service_provider) }

  # describe '#index' do
  #   login_editor(role: :admin)
  #
  #   it 'renders an index page' do
  #     expect(get(:index)).to render_template('admin/opportunities/index')
  #   end
  #
  #   it 'displays the opportunities in reverse date order by default' do
  #     old_opportunity = create(:opportunity, title: 'Test', status: 'publish', created_at: 1.month.ago)
  #     new_opportunity = create(:opportunity, title: 'Test', status: 'publish', created_at: DateTime.current)
  #
  #     get :index
  #
  #     expect(assigns(:opportunities)).to eq [new_opportunity, old_opportunity]
  #   end
  #
  #   it 'sorts by a column chosen by the editor' do
  #     a_opportunity = create(:opportunity, status: 'publish', title: 'AAA')
  #     c_opportunity = create(:opportunity, status: 'publish', title: 'CCC')
  #     b_opportunity = create(:opportunity, status: 'publish', title: 'BBB')
  #
  #     get :index, sort: { column: 'title', order: 'asc' }
  #
  #     expect(assigns(:opportunities)).to eq [a_opportunity, b_opportunity, c_opportunity]
  #   end
  #
  #   it 'sorts by a column and direction chosen by the editor' do
  #     pending_opportunity = create(:opportunity, status: 'pending', title: 'CCC')
  #     published_opportunity = create(:opportunity, status: 'publish', title: 'AAA')
  #
  #     get :index, sort: { column: 'status', order: 'asc' }
  #
  #     expect(assigns(:opportunities)).to eq [pending_opportunity, published_opportunity]
  #   end
  #
  #   it 'sorts by the default column, if an invalid column is passed' do
  #     old_opportunity = create(:opportunity, title: 'Test', status: :publish, created_at: 1.month.ago)
  #     new_opportunity = create(:opportunity, title: 'Test', status: :publish, created_at: DateTime.current)
  #
  #     get :index, sort: { column: 'wintle', order: 'desc' }
  #
  #     expect(assigns(:opportunities)).to eq [new_opportunity, old_opportunity]
  #   end
  #
  #   it 'has a default filter' do
  #     get :index
  #
  #     expect(assigns(:selected_status)).to eq nil
  #   end
  #
  #   context 'filters acceptable search terms' do
  #     it 'rejects non-email punctuation from search terms' do
  #       create(:opportunity, title: 'Test', status: :publish, created_at: 1.month.ago)
  #       expect(OpportunityQuery).to receive(:new).with(a_hash_including(search_term: 'email@example.com drop-table opportunities')).and_call_original
  #       get :index, s: "email@example.com'; -- drop-table opportunities; --"
  #     end
  #
  #     it 'permits email punctuation from search terms' do
  #       create(:opportunity, title: 'Test', status: :publish, created_at: 1.month.ago)
  #       expect(OpportunityQuery).to receive(:new).with(a_hash_including(search_term: 'email@example.com drop-table opportunities')).and_call_original
  #       get :index, s: "email@example.com'; -- drop-table opportunities; --"
  #     end
  #   end
  # end
  #
  # describe '#create' do
  #   login_editor(role: :admin)
  #
  #   it 'adds a new opportunity' do
  #     expect { create_opportunity }.to change { Opportunity.count }.from(0).to(1)
  #
  #     opportunity = Opportunity.last
  #     expect(opportunity.title).to eq 'the opportunity title'
  #     expect(opportunity.slug).to eq 'the-opportunity-title'
  #     expect(opportunity.teaser).to eq 'teaser'
  #     expect(opportunity.description).to eq 'description'
  #   end
  #
  #   it 'changes-duplicate-slugs' do
  #     create_opportunity
  #     first = Opportunity.order(:created_at).last
  #     create_opportunity
  #     second = Opportunity.order(:created_at).last
  #     expect(first.title).to eq(second.title)
  #     expect(first.slug).not_to eq(second.slug)
  #     expect(second.slug).to include(first.slug)
  #   end
  # end
  #
  # describe '#update' do
  #   login_editor(role: :admin)
  #
  #   it 'updates the opportunity' do
  #     opportunity = create(:opportunity)
  #
  #     update_opportunity(opportunity.id)
  #
  #     opportunity.reload
  #     expect(opportunity.title).to eq 'revised opportunity title'
  #     expect(opportunity.slug).to eq 'revised-opportunity-title'
  #     expect(opportunity.teaser).to eq 'teaser'
  #     expect(opportunity.description).to eq 'description'
  #   end
  # end
  #
  # def create_opportunity
  #   post :create, opportunity: {
  #       title: 'the opportunity title',
  #       country_ids: [country.id],
  #       sector_ids: [sector.id],
  #       type_ids: [type.id],
  #       value_ids: [value.id],
  #       teaser: 'teaser',
  #       response_due_on: '2015-02-01',
  #       description: 'description',
  #       contacts_attributes: [
  #           { name: 'foo', email: 'email@foo.com' },
  #           { name: 'bar', email: 'email@bar.com' },
  #       ],
  #       service_provider_id: service_provider.id,
  #   }
  # end
  #
  # def update_opportunity(id)
  #   put :update, id: id, opportunity: {
  #       title: 'revised opportunity title',
  #       country_ids: [country.id],
  #       sector_ids: [sector.id],
  #       type_ids: [type.id],
  #       value_ids: [value.id],
  #       teaser: 'teaser',
  #       response_due_on: '2015-02-01',
  #       description: 'description',
  #       service_provider_id: service_provider.id,
  #   }
  # end
end
