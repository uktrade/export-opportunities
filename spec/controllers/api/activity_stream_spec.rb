require 'hawk'
require 'rails_helper'

def auth_header(ts, key_id, secret_key)
  credentials = {
    id: key_id,
    key: secret_key,
    algorithm: 'sha256',
  }
  return Hawk::Client.build_authorization_header(
    credentials: credentials,
    ts: ts,
    method: 'GET',
    request_uri: '/api/activity_stream',
    host: 'test.host',
    port: '443',
    content_type: '',
    payload: '',
  )
end

RSpec.describe Api::ActivityStreamController, type: :controller do
  describe 'GET feed controller' do
    it 'responds with a 401 error if Authorization header is not set' do
      get :index, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Authorization header is missing"}))
    end

    it 'responds with a 401 if Authorization header is set, but timestamped 61 seconds in the past' do
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i - 61,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Stale ts"}))
    end

    it 'responds with a 401 if Authorization header uses incorrect key ID' do
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID + 'something-incorrect',
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Unidentified id"}))
    end

    it 'responds with a 401 if Authorization header uses incorrect key' do
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY + 'something-incorrect',
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Invalid mac")
    end

    it 'responds with a blank JSON object if Authorization header is set and correct' do
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
      )
      get :index, params: { format: :json }

      expect(response.body).to eq('{}')
      expect(response.headers['Content-Type']).to eq('application/activity+json')
    end
  end
end
