require 'hawk'
require 'uri'

class ActivityStreamUtility
  #
  # This general class is designed to allow you to manually test
  # any Hawk authenticated activity stream endpoint
  # Note all AS endpoints require requests to port 443
  #

  def initialize(id:     Figaro.env.ACTIVITY_STREAM_ACCESS_KEY_ID,
                 secret: Figaro.env.ACTIVITY_STREAM_SECRET_ACCESS_KEY)
    @id = id
    @secret = secret
  end

  def request(url)
    url = "http://#{url}" unless url[0..3] == 'http'
    response = Faraday.get do |request|
      request.url url
      request.headers['Content-Type'] = 'application/json'
      request.headers['X-Forwarded-For'] = '0.0.0.0, 1.2.3.4'
      request.headers['Authorization'] = hawk_authorization(url)
      request.body = ''
    end
    response.body
  end

  private

    def hawk_authorization(url)
      parsed_url = URI.parse(url)
      Hawk::Client.build_authorization_header(
        credentials: {
          id: @id,
          key: @secret,
          algorithm: 'sha256',
        },
        ts: Time.now.getutc.to_i,
        method: 'GET',
        request_uri: parsed_url.path,
        host: parsed_url.host,
        port: '443',
        content_type: 'application/json',
        payload: ''
      )
    end
end
