require 'hawk'
require 'rails_helper'
require 'socket'

RSpec.describe Api::ActivityStreamController, type: :controller do
  describe 'GET feed controller' do
    it 'responds with a 401 error if Authorization header is not set' do
      get :index, params: { format: :json }
      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Authorization header is missing"}))
    end

    it 'responds with a 401 if Authorization header is set, but timestamped 61 seconds in the past' do
      credentials = {
        id: Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        key: Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        algorithm: 'sha256',
      }
      @request.headers['Authorization'] = Hawk::Client.build_authorization_header(
        credentials: credentials,
        ts: Time.now.getutc.to_i - 61,
        method: 'GET',
        request_uri: '/api/activity_stream',
        host: 'test.host',
        port: 80,
      )
      get :index, params: { format: :json }

      expect(response.status).to eq(401)
      expect(response.body).to eq(%({"message":"Stale ts"}))
    end

    it 'responds with a 401 if header is reused' do
      credentials = {
        id: Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        key: Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        algorithm: 'sha256',
      }
      @request.headers['Authorization'] = Hawk::Client.build_authorization_header(
        credentials: credentials,
        ts: Time.now.getutc.to_i,
        method: 'GET',
        request_uri: '/api/activity_stream',
        host: 'test.host',
        port: 80,
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
      credentials = {
        id: Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        key: Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        algorithm: 'sha256',
      }
      @request.headers['Authorization'] = Hawk::Client.build_authorization_header(
        credentials: credentials,
        ts: Time.now.getutc.to_i,
        method: 'GET',
        request_uri: '/api/activity_stream',
        host: 'test.host',
        port: 80,
      )

      begin
        get :index, params: { format: :json }
      rescue SocketError => ex
      end
      expect(ex.backtrace.to_s).to include('/redis/')
    end

    it 'responds with a dummy JSON object if Authorization header is set and correct' do
      credentials = {
        id: Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
        key: Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
        algorithm: 'sha256',
      }
      @request.headers['Authorization'] = Hawk::Client.build_authorization_header(
        credentials: credentials,
        ts: Time.now.getutc.to_i,
        method: 'GET',
        request_uri: '/api/activity_stream',
        host: 'test.host',
        port: 80,
      )
      get :index, params: { format: :json }

      expect(response.body).to eq('{"secret":"content-for-pen-test"}')
      expect(response.headers['Content-Type']).to eq('application/activity+json')
    end
  end
end
