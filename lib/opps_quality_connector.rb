class OppsQualityConnector
  def call(hostname, quality_api_key, quality_text)
    raise Exception, 'invalid input' unless quality_api_key && quality_text

    # input text from OO may contain invalid byte sequence in UTF-8
    quality_text = quality_text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

    response_body = JSON.parse(fetch_response(hostname, quality_api_key, quality_text))

    if response_body['flaggedTokens']
      return { status: 200, score: calculate_score(quality_text, response_body['flaggedTokens'].length), errors: response_body['flaggedTokens'] }
    end

    { status: 404 }
  end

  def calculate_score(quality_text, number_errors)
    number_words = quality_text.split(' ').length

    100 - 100 * (number_errors.to_f / number_words)
  end

  def fetch_response(hostname, quality_api_key, quality_text)
    # header_params = { "Ocp-Apim-Subscription-Key": Figaro.env.TG_API_KEY! }
    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.adapter  Faraday.default_adapter
    end

    begin
      # TODO: refactor this to POST to be able to submit up to 32768 chars.
      response = connection.post hostname.to_s do |req|
        req.headers['Ocp-Apim-Subscription-Key'] = quality_api_key
        req.body = 'Text=' + quality_text.to_json
      end

      response.body
    rescue ArgumentError
      '{}'
    end
  end
end
