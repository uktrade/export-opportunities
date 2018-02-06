class OppsQualityConnector
  def call(hostname, quality_api_key, quality_text)
    raise Exception, 'invalid input' unless quality_api_key && quality_text
    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.adapter  Faraday.default_adapter
    end

    response = connection.get do |req|
      req.url "#{hostname}#{quality_text}&key=#{quality_api_key}"
    end

    response_body = JSON.parse(response.body)

    if response_body['result']
      { status: response_body['result'], score: response_body['score'], errors: response_body['errors'] }
    else
      case response_body['error_code']
      when '600'
        'INVALID LICENSE KEY'
      when '601'
        'TOO MANY REQUESTS PER SECOND'
      when '602'
        'MONTHLY LIMIT REQUEST EXCEEDED'
      when '603'
        'TOO MANY REQUESTS PER DAY'
      when '605'
        'LICENSE KEY EMPTY'
      when '500'
        'GENERIC ERROR'
      when '501'
        'TEXT INPUT IS TOO LONG'
      when '502'
        'TOO MANY ERRORS. NOT ENGLISH?'
      end
      { status: response_body['result'], error_code: response_body['error_code'], description: response_body['description'] }
    end
  end
end