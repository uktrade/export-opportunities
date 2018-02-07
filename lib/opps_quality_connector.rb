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
    # response_body = JSON.parse({ result: false, error_code: 600}.to_json)

    if response_body['result']
      { status: response_body['result'], score: response_body['score'], errors: response_body['errors'] }
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
end
