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

  def data(token, hostname, url, date)
    unless token && hostname && url
      raise Exception, 'invalid input'
    end

    query_params = ''
    unless url.blank?
      now = Time.zone.now
      today_date = now.strftime('%Y-%m-%d')
      query_params = "&date_created=#{date}&max_releasedate=#{today_date}"
    end

    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.options[:timeout] = 15
      f.adapter Faraday.default_adapter
    end

    response = connection.get do |req|
      req.url hostname + url + query_params
      req.headers['Authorization'] = 'JWT ' + token
    end

    response_body = JSON.parse(response.body)
    has_next ||= response_body['next']

    { data: response_body['results'], has_next: has_next, next_url: response_body['next'], status: response.status, count: response_body['count'] }
  rescue JSON::ParserError => e
    Rails.logger.error 'Can\'t parse JSON result. Probably an Application Error 500 on VO side'
    redis = Redis.new(url: Figaro.env.REDIS_URL!)
    redis.set(:application_error, Time.zone.now)
    raise e
  end
end
