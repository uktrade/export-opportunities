require 'rails_helper'

RSpec.describe VolumeOppsRetriever do
  describe '#call' do
    it 'retrieves opps in volume' do
      editor = create(:editor)
      country = create(:country, id: '11')
      create(:sector, id: '2')
      create(:type, id: '3')
      create(:value, id: '3')
      create(:service_provider, id: '150', country: country)

      allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_token).and_return(OpenStruct.new(body: "{\"token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9\"}"))
      allow_any_instance_of(OpportunitySensitivityRetriever).to receive(:personal_identifiable_information).and_return({name: 'Mark Lytollis', phone: '02072155000'})

      file_response = File.read('spec/files/volume_opps/response_hash.json')
      response_opps = JSON.parse(file_response, quirks_mode: true)
      json_response_opps = JSON.parse(response_opps).with_indifferent_access
      allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_data).and_return(json_response_opps)

      res = VolumeOppsRetriever.new.call(editor, '2018-04-16')

      expect(res[0][:ocid]).to eq('ocds-0c46vo-0018-19461899')
      expect(res[0][:json][:releases][0][:buyer][:contactPoint][:name]).to eq('Mark Lytollis, 02072155000')
    end

    it 'retrieves opps in volume, an opp that already exists' do
      editor = create(:editor)
      country = create(:country, id: '11', name: 'New Zealand')
      create(:sector, id: '2')
      create(:type, id: '3')
      create(:type, id: '2')
      create(:value, id: '2')
      create(:service_provider, id: '150', country: country)

      allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_token).and_return(OpenStruct.new(body: "{\"token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9\"}"))
      allow_any_instance_of(OpportunitySensitivityRetriever).to receive(:personal_identifiable_information).and_return({name: 'Mark Lytollis', phone: '02072155000'})

      file_response = File.read('spec/files/volume_opps/response_hash.json')
      response_opps = JSON.parse(file_response, quirks_mode: true)
      json_response_opps = JSON.parse(response_opps).with_indifferent_access
      allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_data).and_return(json_response_opps)

      VolumeOppsRetriever.new.call(editor, '2018-04-16')

      res = VolumeOppsRetriever.new.call(editor, '2018-04-16')

      expect(res[0][:ocid]).to eq('ocds-0c46vo-0018-19461899')
      expect(res[0][:json][:releases][0][:buyer][:contactPoint][:name]).to eq('Mark Lytollis, 02072155000')
    end
  end

  describe '#contact_attributes' do
    it 'returns nil if no contactpoint present' do
      res = VolumeOppsRetriever.new.contact_attributes({})
      expect(res[0][:name]).to eq nil
      expect(res[0][:email]).to eq nil
    end

    it 'strips email/address from name field, adds them to email overwriting existing entry' do
      res = VolumeOppsRetriever.new.contact_attributes({contactPoint: {name: 'alex giamas agiamasat@gmail.com Westminster, London SW1A 1AA', email: 'aninvalidemail'}}.with_indifferent_access)

      expect(res[0][:name]).not_to include('agiamasat@gmail.com')
      expect(res[0][:email]).to eq('agiamasat@gmail.com')
    end

    it 'strips address from email field' do
      skip('TODO: implement')
    end
  end

  describe '#calculate_value' do
    it 'converts values to GBP in opps, from a known currency, using seed exchange data, under 100,000GBP' do
      gbp_value = VolumeOppsRetriever.new.calculate_value(OpenStruct.new({amount: 1000, currency: 'PHP'}))

      expect(gbp_value[:id]).to eq 1
      expect(gbp_value[:gbp_value]).to eq 13.77
    end

    it 'converts values to GBP in opps, from a known currency, using seed exchange data, over 100,000GBP' do
      gbp_value = VolumeOppsRetriever.new.calculate_value(OpenStruct.new({amount: 141487.75, currency: 'USD'}))

      expect(gbp_value[:id]).to eq 3
      expect(gbp_value[:gbp_value]).to eq 100000.0
    end

    it 'converts values to GBP in opps, from an unknown currency' do
      gbp_value = VolumeOppsRetriever.new.calculate_value(OpenStruct.new({amount: 100000000, currency: 'GRD'}))

      expect(gbp_value[:id]).to eq 1
      expect(gbp_value[:gbp_value]).to eq -1
    end
  end
end
