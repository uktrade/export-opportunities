require 'net/http'

##### Index
# Category1 represents the potential presence of language that may be considered sexually explicit or adult in certain situations.
# Category2 represents the potential presence of language that may be considered sexually suggestive or mature in certain situations.
# Category3 represents the potential presence of language that may be considered offensive in certain situations.
# Score range is between 0 and 1. The higher the score, higher the likelihood of the category being applicable.
# ReviewRecommended is either true or false depending on the internal score thresholds. Customers are recommended to either use this value or decide
# on custom thresholds based on their content policies. In the preceding example,
# ReviewRecommended is true because of the high score assigned to Category3.
class OppsSensitivityConnector
  def call(text, hostname, sensitivity_api_key)
    Rails.logger.error('VOLUMEOPS - Sensitivity Connector starting...')
    uri = URI(hostname)
    uri.query = URI.encode_www_form(
      autocorrect: false,
      PII: true,
      classify: true,
      listId: Figaro.env.AZ_CUSTOM_LIST_ID.to_i,
      language: 'eng'
    )

    request = Net::HTTP::Post.new(uri.request_uri)
    # Request headers
    request['Content-Type'] = 'text/plain'
    # Request headers
    request['Ocp-Apim-Subscription-Key'] = sensitivity_api_key
    # Request body
    request.body = text

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    Rails.logger.error('VOLUMEOPS - Sensitivity Connector starting... done')
    response.body
  end
end
