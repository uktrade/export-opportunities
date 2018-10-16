require 'rails_helper'
require 'opps_quality_connector'

describe OpportunityQualityRetriever, type: :service do
  describe '#call' do
    it 'returns a valid response even when errors found' do
      opportunity = create(:opportunity, id: 1)
      opportunity.title = 'I was notoriously bad at speling beee copetitions.'
      opportunity.description = 'Realy budd'

      opportunity.save!

      response = OpportunityQualityRetriever.new.call(opportunity)

      expect(response.length).to eq 4

      first_error = response[0]

      expect(first_error.score).to eq 60
      expect(first_error.submitted_text).to eq "#{opportunity.title} #{opportunity.description}"
      expect(first_error.offensive_term).to eq 'speling'
      expect(first_error.suggested_term).to eq 'spelling'
      expect(first_error.opportunity_id).to eq opportunity.id
    end

    it 'succeeds when MS doesnt find any errors' do
      opportunity = create(:opportunity, id: 1)
      allow_any_instance_of(OpportunityQualityRetriever).to receive(:quality_check).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, "#{opportunity.title} #{opportunity.description}").and_return({:status=>200, :score=>100.0, :errors=>[]})

      response = OpportunityQualityRetriever.new.call(opportunity)

      expect(response[0].submitted_text).to eq "#{opportunity.title} #{opportunity.description}"
      expect(response[0].error_id).to eq nil
      expect(response[0].score).to eq 100
    end

    it 'doesnt fail when MS returns invalid response' do
      opportunity = create(:opportunity, id: 1)
      allow_any_instance_of(OpportunityQualityRetriever).to receive(:quality_check).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, "#{opportunity.title} #{opportunity.description}").and_return({:status=>200, :score=>100.0})

      response = OpportunityQualityRetriever.new.call(opportunity)

      expect(response[0].error_id).to eq nil
      expect(response[0].score).to eq 100
    end
  end
end
