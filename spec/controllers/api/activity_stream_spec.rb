require 'hawk'
require 'rails_helper'
require 'socket'

def auth_header(ts, key_id, secret_key, payload)
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
    payload: payload,
  )
end

RSpec.describe Api::ActivityStreamController, type: :controller do
  describe 'GET feed controller' do
    it 'responds with a 401 error if connecting from unauthorized IP' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('1.2.3.4')
      get :index, params: { format: :json }
      expect(response.body).to eq(%({"message":"Connecting from unauthorized IP"}))
    end
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
        '',
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Stale ts"}))
    end

    it 'responds with a 401 if Authorization header misses ts' do
      @request.headers['Authorization'] = 'Hawk mac="a", hash="b", nonce="c"'
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing ts")
    end

    it 'responds with a 401 if Authorization header has non integer ts' do
      @request.headers['Authorization'] = 'Hawk ts="a" mac="a" hash="b" nonce="c"'
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Invalid ts")
    end

    it 'responds with a 401 if Authorization header misses mac' do
      @request.headers['Authorization'] = 'Hawk ts="1", hash="b", nonce="c"'
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing mac")
    end

    it 'responds with a 401 if Authorization header misses hash' do
      @request.headers['Authorization'] = 'Hawk ts="1", mac="a", nonce="c"'
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing hash")
    end

    it 'responds with a 401 if Authorization header misses nonce' do
      @request.headers['Authorization'] = 'Hawk ts="1", mac="a"'
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Missing hash")
    end

    it 'responds with a 401 if Authorization header uses incorrect key ID' do
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID + 'something-incorrect',
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        '',
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
        '',
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Invalid mac")
    end

    it 'responds with a 401 if Authorization header uses incorrect payload' do
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        'something-incorrect',
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to include("Invalid hash")
    end

    it 'responds with a 401 if header is reused' do
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        '',
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
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        '',
      )
      begin
        get :index, params: { format: :json }
      rescue SocketError => ex
      end
      expect(ex.backtrace.to_s).to include('/redis/')
    end

    it 'responds with a dummy JSON object if Authorization header is set and correct' do
      @request.headers['Authorization'] = auth_header(
        Time.now.getutc.to_i,
        Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        '',
      )
      get :index, params: { format: :json }

      expect(response.body).to eq('{"secret":"content-for-pen-test"}')
      expect(response.headers['Content-Type']).to eq('application/activity+json')
    end
  end
end
