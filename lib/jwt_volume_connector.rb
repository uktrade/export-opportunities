class JwtVolumeConnector
  def call(username, password, hostname, url)
    token = self.token(username, password, hostname, url)
    data(token, hostname, url, from_date, to_date)
  end

  def token(username, password, hostname, url)
    unless username && password && hostname && url
      raise Exception, 'invalid input'
    end

    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.adapter  Faraday.default_adapter
    end

    post = connection.post do |req|
      req.url hostname + url
      req.headers['Content-Type'] = 'application/json'
      req.body = "{ \"username\": \"#{username}\", \"password\": \"#{password}\" }"
    end
    post
  end

  def data(token, hostname, url, from_date, to_date)
    unless token && hostname && url
      raise Exception, 'invalid input'
    end

    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.options[:timeout] = 15
      f.adapter Faraday.default_adapter
    end

    response = connection.get do |req|
      req.url hostname + url + "&release_date__gte=#{from_date}&release_date__lte=#{to_date}"
      req.headers['Authorization'] = 'Bearer ' + token
    end
    response_body = rectify_payload(JSON.parse(response.body), response.env.url)
    has_next ||= response_body['next']

    {
      data: response_body['results'],
      has_next: has_next,
      next_url: response_body['next'],
      status: response.status,
      count: response_body['count']
    }
  rescue JSON::ParserError => e
    Rails.logger.error 'Can\'t parse JSON result. Probably an Application Error 500 on VO side'
    redis = Redis.new(url: Figaro.env.REDIS_URL!)
    redis.set(:application_error, Time.zone.now)
    raise e
  end

  private

  def rectify_payload(body, url)
    max_limit = 9900
    count = body['result_count']
    offset = body['offset']
    limit = body['limit']
    if (offset < max_limit) && (((count - offset) / limit).positive?)
      body['next'] = build_next_url(url, offset + limit)
    end
    body
  end

  def build_next_url(url, next_offset)
    query = Rack::Utils.parse_query(url.query)
    query['offset'] = next_offset
    url.query = Rack::Utils.build_query(query)
    url.to_s
  end
end
