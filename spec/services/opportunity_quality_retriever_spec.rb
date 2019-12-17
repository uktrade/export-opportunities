require 'rails_helper'
require 'opps_quality_connector'

describe OpportunityQualityRetriever, type: :service do
  describe '#call' do
    it "creates an error when the API fails" do
      cached_TG_API_KEY = ENV["TG_API_KEY"]
      ENV["TG_API_KEY"] = "broken"
            
      # Test oddly needs to be run before the message is logged
      error_msg = /QualityCheck API failed. API returned status 404/
      expect(Rails.logger).to receive(:error).with(error_msg).ordered

      opportunity = create(:opportunity)
      checks = OpportunityQualityRetriever.new.call(opportunity)

      ENV["TG_API_KEY"] = cached_TG_API_KEY
    end
    it "creates a non-error OpportunityCheck when the check passes" do
      opportunity = create(:opportunity, id: 1,
        title: 'Opportunity with no errors',
        description: 'Fine')

      checks = OpportunityQualityRetriever.new.call(opportunity)

      expect(checks.length).to eq 1

      expect(checks[0].score).to eq 100
      expect(checks[0].submitted_text).to eq "#{opportunity.title} #{opportunity.description}"
      expect(checks[0].opportunity_id).to eq opportunity.id
      expect(checks[0].error_id).to eq nil
    end
    it "creates one error-based OpportunityCheck for each error in text" do
      opportunity = create(:opportunity, id: 1,
        title: 'Opportunity with four errors: speling beee copetitions.',
        description: 'Realy bad')

      checks = OpportunityQualityRetriever.new.call(opportunity)

      expect(checks.length).to eq 4

      expect(checks[0].submitted_text).to eq "#{opportunity.title} #{opportunity.description}"
      expect(checks[0].opportunity_id).to eq opportunity.id
      expect(checks[0].offensive_term).to eq 'speling'
      expect(checks[0].suggested_term).to eq 'spelling'
      expect(checks[0].score).to eq 55
      expect(checks[0].error_id).to eq opportunity.id
    end

        # Tests the behaviour of the quality scoring
    it 'Identifies spelling errors and suggests improved spelling' do
      opportunity = create(:opportunity,
                           title: 'Opportunity with errrors',
                           description: 'Not Fiine')

      checks = OpportunityQualityRetriever.new.call(opportunity)

      expect(checks[0].offensive_term).to eq 'errrors'
      expect(checks[0].suggested_term).to eq 'errors'
      expect(checks[0].score).to eq 60
      expect(checks[0].error_id).to eq opportunity.id
    end
    it 'Scores opportunities with no errors as 100' do
      opportunity = create(:opportunity,
                           title: 'Opportunity with no errors',
                           description: "fine")

      checks = OpportunityQualityRetriever.new.call(opportunity)

      expect(checks[0].score).to eq 100
    end
    it 'Accepts British spelling' do
      opportunity = create(:opportunity,
                           title: "monetise realise",
                           description: "theatre fibre")
      checks = OpportunityQualityRetriever.new.call(opportunity)
      expect(checks[0].score).to eq 100
    end
    it 'Accepts US spelling' do
      opportunity = create(:opportunity,
                           title: "monetize realize",
                           description: "theater fiber")
      checks = OpportunityQualityRetriever.new.call(opportunity)
      expect(checks[0].score).to eq 100
    end
    it 'Assigns boundaries of "limit" and "offset" to spelling mistakes' do
      opportunity = create(:opportunity,
                           title: 'Opportunity title with spelljhkhjjkhjhjkkhling error.',
                           description: 'description')
      checks = OpportunityQualityRetriever.new.call(opportunity)
      offset = checks[0].offset
      length = checks[0].length
      if offset && length
        mistake = "spelljhkhjjkhjhjkkhling"
        segment_with_mistake = "#{opportunity.title} #{opportunity.description}"[offset...offset+length]
        expect(segment_with_mistake).to eq(mistake)
      end
    end
  end
end
