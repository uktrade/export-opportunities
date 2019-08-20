require 'uri'

class HawkUtility
  #
  # This general class is designed to allow you to manually test
  # any Hawk authenticated activity stream endpoint
  # Note all AS endpoints require requests to port 443
  #

  def initialize
    @sender_id = 'directory'
    @secret = 'debug'
    @host = ''
    @port = 'None'
    @path = '/public/company/10000000/'
    @version = '14.0.0'
    @method = 'GET'
    @body = ''
    @content_type = 'text/plain'
  end

  def request
    response = Faraday.get do |request|
      request.url url
      request.headers['User-agent'] = "EXPORT-DIRECTORY-API-CLIENT/#{@version}"
      request.headers['Content-Type'] = @content_type
      request.headers['X-Signature'] = header
      request.body = @body
    end
    response.body
  end

  def header
    Hawk::Client.build_authorization_header(
      credentials: {
        id: @sender_id,
        key: @secret,
        algorithm: 'sha256',
      },
      method: 'GET',
      host: @host,
      port: @port,
      request_uri: @path,
      content_type: @content_type,
      payload: @body
    )
  end
end
# HawkUtility.new.header
