require 'rails_helper'

RSpec.describe JwtVolumeConnector do
  describe '#call' do
    it 'calls a default endpoint and returns token' do
      res = JwtVolumeConnector.new.token(Figaro.env.OO_USERNAME!, Figaro.env.OO_PASSWORD!, Figaro.env.OO_HOSTNAME!, Figaro.env.OO_TOKEN_ENDPOINT!)
      body = JSON.parse(res.body)
      expect(res.status).to eq(200)
      expect(body['token']).to_not eq(nil)
    end

    it 'uses the token from an endpoint to fetch data' do
      token_response = JwtVolumeConnector.new.token(Figaro.env.OO_USERNAME!, Figaro.env.OO_PASSWORD!, Figaro.env.OO_HOSTNAME!, Figaro.env.OO_TOKEN_ENDPOINT!)

      res = JwtVolumeConnector.new.data(JSON.parse(token_response.body)['token'],Figaro.env.OO_HOSTNAME!, Figaro.env.OO_DATA_ENDPOINT!, '2018-04-16', '2018-04-16')

      results = res[:data]
      expect(res[:status]).to eq(200)
      expect(results).to be_instance_of(Array)
      expect(res[:count]).to be >= 0
    end
  end
end
