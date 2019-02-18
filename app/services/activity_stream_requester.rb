require 'hawk'

class ActivityStreamRequester

  def call
    response = Faraday.get do |request|
      request.url 'http://localhost:3001/api/activity_stream/opportunities'
      request.headers['Content-Type'] = 'application/json'
      request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      request.headers['Authorization'] = hawk_authorization
      request.body = ''
    end
    response.body
  end

  private

    def hawk_authorization
      Hawk::Client.build_authorization_header(
        credentials: {
          id: Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
          key: Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY,
          algorithm: 'sha256',
        },
        ts: Time.now.getutc.to_i,
        method: 'GET',
        request_uri: '/api/activity_stream/opportunities',
        host: 'localhost',
        port: '3001',
        content_type: 'application/json',
        payload: ''
      )
    end

end