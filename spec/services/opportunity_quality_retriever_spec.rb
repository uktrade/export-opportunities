require 'rails_helper'
require 'opps_quality_connector'

describe OpportunityQualityRetriever, type: :service do
  describe '#call' do
    it 'returns valid when no errors found' do
      opportunity = create(:opportunity, id: 1)
      no_errors_result = File.read('spec/files/quality_opps/no_errors_check.json')
      no_errors_result_json = JSON.parse(no_errors_result).with_indifferent_access

      allow_any_instance_of(OpportunityQualityRetriever).to receive(:quality_check).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, "#{opportunity.title} #{opportunity.description}").and_return(no_errors_result_json)

      response = OpportunityQualityRetriever.new.call(opportunity)

      expect(response.score).to eq 100
      expect(response.submitted_text).to eq "#{opportunity.title} #{opportunity.description}"
      expect(response.error_id).to eq nil
      expect(response.opportunity_id).to eq opportunity.id
    end

    it 'returns valid when errors found' do
      opportunity = create(:opportunity, id: 1)
      errors_result = File.read('spec/files/quality_opps/errors_check.json')
      errors_result_json = JSON.parse(errors_result).with_indifferent_access

      allow_any_instance_of(OpportunityQualityRetriever).to receive(:quality_check).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, "#{opportunity.title} #{opportunity.description}").and_return(errors_result_json)

      response = OpportunityQualityRetriever.new.call(opportunity)

      expect(response.score).to eq 33
      expect(response.submitted_text).to eq "#{opportunity.title} #{opportunity.description}"
      expect(response.offensive_term).to eq 'UD'
      expect(response.suggested_term).to eq 'US'
      expect(response.opportunity_id).to eq opportunity.id
    end
  end
end
