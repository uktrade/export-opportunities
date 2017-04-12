require 'rails_helper'

describe UpdateOpportunity, type: :service do
  describe '#call' do
    it 'updates the opportunity' do
      opportunity = create(:opportunity, id: '4030bdeb-7fb1-44d9-a6d6-ac3e5a6d3d46')

      UpdateOpportunity.new(opportunity).call(opportunity_params(title: 'Export Pens To Pennsylvania'))

      opportunity.reload
      expect(opportunity.title).to eq 'Export Pens To Pennsylvania'
      expect(opportunity.slug).to eq 'export-pens-to-pennsylvania'
      expect(opportunity.description).to eq 'description'
    end

    it 'returns the opportunity' do
      opportunity = create(:opportunity)

      response = UpdateOpportunity.new(opportunity).call(opportunity_params)

      expect(response).to eq opportunity
    end

    def opportunity_params(title: 'title')
      {
        title: title,
        country_ids: [create(:country).id],
        sector_ids: [create(:sector).id],
        type_ids: [create(:type).id],
        value_ids: [create(:value).id],
        teaser: 'teaser',
        response_due_on: '2015-02-01',
        description: 'description',
        service_provider_id: create(:service_provider).id,
      }
    end
  end
end
