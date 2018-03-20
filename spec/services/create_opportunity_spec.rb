require 'rails_helper'

describe CreateOpportunity, type: :service do
  describe '#call' do
    before do
      country = create(:country, id: '1')
      create(:sector, id: '2')
      create(:type, id: '3')
      create(:value, id: '4')
      @service_provider = create(:service_provider, id: '5', country: country)
    end

    it 'creates a new opportunity' do
      service_provider = create(:service_provider)
      editor = create(:editor, service_provider_id: service_provider.id)

      expect { CreateOpportunity.new(editor).call(opportunity_params) }
        .to change { Opportunity.count }.by(1)
    end

    it 'returns an opportunity' do
      editor = create(:editor)

      response = CreateOpportunity.new(editor).call(opportunity_params)

      expect(response).to be_a Opportunity
    end

    it 'sets status as pending' do
      editor = create(:editor, service_provider: @service_provider)

      response = CreateOpportunity.new(editor).call(opportunity_params)

      expect(response.status).to eq 'pending'
    end

    it 'assigns the editor as the author' do
      editor = create(:editor, service_provider: @service_provider)

      response = CreateOpportunity.new(editor).call(opportunity_params)

      expect(response.author).to eq editor
    end

    it "creates a slug from an opportunity's title" do
      editor = create(:editor)
      params = opportunity_params(title: 'Export Great Britain to Great Nations For Fun & Profit!')
      response = CreateOpportunity.new(editor).call(params)
      expect(response.slug).to eq 'export-great-britain-to-great-nations-for-fun-profit'
    end

    it 'ensures an editor-entered slug is in the right format' do
      editor = create(:editor)
      params = opportunity_params.merge(slug: 'badly formatted SLUG')

      response = CreateOpportunity.new(editor).call(params)

      expect(response.slug).to eql 'badly-formatted-slug'
    end
  end
end

def opportunity_params(title: 'title')
  {
    title: title,
    country_ids: ['1'],
    sector_ids: ['2'],
    type_ids: ['3'],
    value_ids: ['4'],
    teaser: 'teaser',
    response_due_on: '2015-02-01',
    description: 'description',
    contacts_attributes: [
      { name: 'foo', email: 'email@foo.com' },
      { name: 'bar', email: 'email@bar.com' },
    ],
    service_provider_id: '5',
  }
end
