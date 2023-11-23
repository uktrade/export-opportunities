require 'rails_helper'

=begin
NOTE: The OppsQualityConnector feature no longer works, and has been depreciated. The original service that OppsQualityConnector
called was https://api.cognitive.microsoft.com/bing/v7.0/SpellCheck. This service has now been moved to
https://api.bing.microsoft.com/v7.0/spellcheck. If this product is ever re-written in future (likely in Python and as
part of great-cms, then the TG_HOSTNAME Env var on Vault will need to be updated to the new API endpoint:
https://api.bing.microsoft.com/v7.0/spellcheck. A new API key will also have to be acquired, and placed in the Env Var
TG_API_KEY.
=end

RSpec.describe OppsQualityConnector do
  describe '#call' do
    it 'calls quality connector with NO errors in submitted text' do
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({"_type"=>"SpellCheck", "flaggedTokens"=>[]}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq 200
      expect(response[:score]).to eq 100
      expect(response[:errors]).to eq []
    end

    it 'calls quality connector with errors in submitted text' do
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({"_type"=>"SpellCheck", "flaggedTokens"=>[{"offset"=>10, "token"=>"ut", "type"=>"UnknownToken", "suggestions"=>[{"suggestion"=>"UT", "score"=>0.875}]}]}.to_json)


      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq 200
      expect(response[:score]).to_not eq 100
      expect(response[:errors][0]['suggestions']).to eq [{"suggestion"=>"UT", "score"=>0.875}]
    end

    it 'calls quality connector with NO errors in submitted text, 600 code error' do
      skip('TODO: refactor for MS spell check that has different error codes')
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({result: false, error_code: 600, description: ''}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq false
      expect(response[:error_code]).to eq 600
      expect(response[:description]).to eq 'INVALID LICENSE KEY'
    end

    it 'calls quality connector with NO errors in submitted text, 601 code error' do
      skip('TODO: refactor for MS spell check that has different error codes')
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({result: false, error_code: 601, description: ''}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq false
      expect(response[:error_code]).to eq 601
    end

    it 'calls quality connector with NO errors in submitted text, 602 code error' do
      skip('TODO: refactor for MS spell check that has different error codes')
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({result: false, error_code: 602, description: ''}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq false
      expect(response[:error_code]).to eq 602
    end

    it 'calls quality connector with NO errors in submitted text, 603 code error' do
      skip('TODO: refactor for MS spell check that has different error codes')
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({result: false, error_code: 603, description: ''}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq false
      expect(response[:error_code]).to eq 603
    end

    it 'calls quality connector with NO errors in submitted text, 605 code error' do
      skip('TODO: refactor for MS spell check that has different error codes')
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({result: false, error_code: 605, description: ''}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq false
      expect(response[:error_code]).to eq 605
    end

    it 'calls quality connector with NO errors in submitted text, 500 code error' do
      skip('TODO: refactor for MS spell check that has different error codes')
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({result: false, error_code: 500, description: ''}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq false
      expect(response[:error_code]).to eq 500
      expect(response[:description]).to eq 'GENERIC ERROR'
    end

    it 'calls quality connector with NO errors in submitted text, 501 code error' do
      skip('TODO: refactor for MS spell check that has different error codes')
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({result: false, error_code: 501, description: ''}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq false
      expect(response[:error_code]).to eq 501
    end

    it 'calls quality connector with NO errors in submitted text, 502 code error' do
      skip('TODO: refactor for MS spell check that has different error codes')
      opportunity = create(:opportunity, id: 1)

      allow_any_instance_of(OppsQualityConnector).to receive(:fetch_response).with(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title).and_return({result: false, error_code: 502, description: ''}.to_json)

      response = OppsQualityConnector.new.call(Figaro.env.TG_HOSTNAME!, Figaro.env.TG_API_KEY!, opportunity.title)

      expect(response[:status]).to eq false
      expect(response[:error_code]).to eq 502
    end
  end
end
