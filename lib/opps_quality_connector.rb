class OppsQualityConnector
  def call(hostname, quality_api_key, quality_text)
    raise Exception, 'invalid input' unless quality_api_key && quality_text
    quality_text = quality_text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    response_body = JSON.parse(fetch_response(hostname, quality_api_key, quality_text))

    if response_body['result']
      if response_body['score']
        { status: response_body['result'], score: response_body['score'], errors: response_body['errors'] }
      else
        { status: response_body['result'], score: 100, errors: {} }
      end
    else
      case response_body['error_code']
      when 600
        description = 'INVALID LICENSE KEY'
      when 601
        description = 'TOO MANY REQUESTS PER SECOND'
      when 602
        description = 'MONTHLY LIMIT REQUEST EXCEEDED'
      when 603
        description = 'TOO MANY REQUESTS PER DAY'
      when 605
        description = 'LICENSE KEY EMPTY'
      when 500
        description = 'GENERIC ERROR'
      when 501
        description = 'TEXT INPUT IS TOO LONG'
      when 502
        description = 'TOO MANY ERRORS. NOT ENGLISH?'
      end

      { status: response_body['result'], error_code: response_body['error_code'], description: description }
    end
  end

  def fetch_response(hostname, quality_api_key, quality_text)
    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.adapter  Faraday.default_adapter
    end

    #TODO: refactor this to POST to be able to submit up to 32768 chars.
    response = connection.get do |req|
      req.url "#{hostname}#{quality_text}&key=#{quality_api_key}"
    end

    response.body
  end
end
