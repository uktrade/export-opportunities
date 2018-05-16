require 'hawk'
require 'rails_helper'

RSpec.describe Api::ActivityStreamController, type: :controller do
  describe 'GET feed controller' do
    it 'responds with a 401 error if Authorization header is not set' do
      get :index, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Authorization header is missing"}))
    end

    it 'responds with a 401 if Authorization header is set, but timestamped 61 seconds in the past' do
      credentials = {
        :id => Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        :key => Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        :algorithm => "sha256"
      }
      @request.headers['Authorization'] = Hawk::Client.build_authorization_header(
        :credentials => credentials,
        :ts => Time.now.getutc.to_i - 61,
        :method => 'GET',
        :request_uri => '/api/activity_stream',
        :host => 'test.host',
        :port => 80,
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Stale ts"}))
    end

    it 'responds with a blank JSON object if Authorization header is set and correct' do
      credentials = {
        :id => Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        :key => Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        :algorithm => "sha256"
      }
      @request.headers['Authorization'] = Hawk::Client.build_authorization_header(
        :credentials => credentials,
        :ts => Time.now.getutc.to_i,
        :method => 'GET',
        :request_uri => '/api/activity_stream',
        :host => 'test.host',
        :port => 80,
      )
      get :index, params: { format: :json }

      expect(response.body).to eq('{}')
      expect(response.headers['Content-Type']).to eq('application/activity+json')
    end
  end
end
