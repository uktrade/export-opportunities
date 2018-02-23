require 'net/http'

class OppsSensitivityConnector
  def call(text)
    uri = URI(Figaro.env.AZ_HOSTNAME!)
    uri.query = URI.encode_www_form(
      autocorrect: false,
      PII: true,
      classify: true,
      language: 'eng'
    )

    request = Net::HTTP::Post.new(uri.request_uri)
    # Request headers
    request['Content-Type'] = 'text/plain'
    # Request headers
    request['Ocp-Apim-Subscription-Key'] = Figaro.env.AZ_API_KEY!
    # Request body
    request.body = text

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    Rails.logger.info response.body
  end
end
