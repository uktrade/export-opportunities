require 'net/http'

class TranslationConnector
  def call(opportunity_params, configuration, opportunity_language, hostname, translation_api_key)
    configuration.each do |config|
      uri = URI(hostname)
      header = { 'Content-Type': 'application/x-www-form-urlencoded' }
      body = URI.encode_www_form(
        auth_key: translation_api_key,
        text: opportunity_params[config],
        target_lang: 'en',
        source_lang: opportunity_language
      )

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      # raise an Error if we reach our monthly quota
      raise 'Translation Quota Exceeded' if response.code == '456'
      # also raise any other errors from translation API if it's not HTTP OK 200
      raise "Error code:#{response.code}" if response.code != '200'

      body = JSON.parse(response.body)
      text = body['translations'][0]['text']

      # assign translated value in place
      opportunity_params[config] = text

      opportunity_params['original_language'] = opportunity_language.downcase
    end
  end
end
