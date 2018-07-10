require 'hawk'
require 'rails_helper'
require 'socket'

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
    it 'responds with a 401 error if connecting from unauthorized IP' do
      # The whitelist is 0.0.0.0, and we reject all requests that don't have
      # 0.0.0.0 as the second-to-last IP in X-Fowarded-For, as this isn't
      # spoofable in PaaS
      get :index, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '1.2.3.4'
      get :index, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '0.0.0.0'
      get :index, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '1.2.3.4, 0.0.0.0'
      get :index, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4, 123.123.123'
      get :index, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))

      @request.headers['X-Forwarded-For'] = '1.2.3.4, 123.123.123, 0.0.0.0'
      get :index, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))
    end
    it 'responds with a 401 error if Authorization header is not set' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      get :index, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Authorization header is missing"}))
    end

    it 'responds with a 401 if Authorization header is set, but timestamped 61 seconds in the past' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
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
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
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
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY + 'something-incorrect',
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Invalid mac")
    end

    it 'responds with a 401 if header is reused' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(200)

      get :index, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Invalid nonce"}))
    end

    it 'bubbles an error if Authorization header is correct, but Redis is down' do
      # This test deliberately does not mock the Redis class to raise an Error.
      # This might be brittle with respect to internals of the Redis class, but
      # this is chosen as better than assuming that Redis behaves a certain way
      # in the case of socket errors, since, within reason, it's better for the
      # test to fail too much than too little.
      allow_any_instance_of(Socket).to receive(:connect_nonblock).and_raise(SocketError)
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
      )
      begin
        get :index, params: { format: :json }
      rescue SocketError => ex
      end
      expect(ex.backtrace.to_s).to include('/redis/')
    end

    it 'responds with a dummy JSON object if Authorization header is set and correct' do
      @request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
      )
      get :index, params: { format: :json }

      expect(response.body).to eq('{"secret":"content-for-pen-test"}')
      expect(response.headers['Content-Type']).to eq('application/activity+json')
    end
  end
end
