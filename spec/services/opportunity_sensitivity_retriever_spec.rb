require 'rails_helper'
# require 'opps_sensitivity_connector'

describe OpportunitySensitivityRetriever, type: :service do
  describe '#call' do
    it 'returns valid when no errors found' do
     skip('TODO: implement')
    end
  end

  describe '#personal_identifiable_information' do
    it 'returns PII when there is one' do
      response = OpportunitySensitivityRetriever.new.personal_identifiable_information('agiamasat@gmail.com 3 whitehall place, london, sw1a2aw')
      expect(response[:email]).to eq('agiamasat@gmail.com')
    end

    it 'returns the first email/address/phone when there are multiple' do
      response = OpportunitySensitivityRetriever.new.personal_identifiable_information('agiamasat@gmail.com drliamfox@gov.uk 3 whitehall place, london, sw1a2aw')
      expect(response[:email]).to eq('agiamasat@gmail.com')
    end
  end
end

