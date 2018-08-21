require 'net/http'

class TranslationConnector
  def call(opportunity, configuration, hostname, translation_api_key)
    configuration.each do |config|
      uri = URI(hostname)
      uri.query = URI.encode_www_form(
        auth_key: translation_api_key,
        text: opportunity[config],
        target_lang: 'en'
      )

      request = Net::HTTP::Post.new(uri.request_uri)
      # Request headers
      request['Content-Type'] = 'application/x-www-form-urlencoded'

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end

      body = JSON.parse(response.body)
      source_language = body['translations'][0]['detected_source_language']
      text = body['translations'][0]['text']

      Rails.logger.debug ">>original text: #{opportunity[config]}"
      Rails.logger.debug ">>>translated text: #{text}"

      # assign translated value in place
      opportunity[config] = text

      opportunity['original_language'] = source_language.downcase
    end
    opportunity.save!
  end
end
