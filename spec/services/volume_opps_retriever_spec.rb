require 'rails_helper'

RSpec.describe VolumeOppsRetriever do
  it 'retrieves opps in volume' do
    editor = create(:editor)
    country = create(:country, id: '11')
    create(:sector, id: '2')
    create(:type, id: '3')
    create(:value, id: '3')
    create(:service_provider, id: '5', country: country)

    allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_token).and_return(OpenStruct.new(body: "{\"token\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9\"}"))

    file_response = File.read('spec/files/volume_opps/response_hash.json')
    response_opps = JSON.parse(file_response, quirks_mode: true)
    json_response_opps = JSON.parse(response_opps).with_indifferent_access
    allow_any_instance_of(VolumeOppsRetriever).to receive(:jwt_volume_connector_data).and_return(json_response_opps)

    VolumeOppsRetriever.new.call(editor)
  end

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
