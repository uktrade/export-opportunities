class JwtVolumeConnector
  def call(username, password, hostname, url)
    Rails.logger.error("VOLUMEOPS - Getting JWT...")
    token = self.token(username, password, hostname, url)
    data(token, hostname, url, from_date, to_date)
  end

  def token(username, password, hostname, url)
    Rails.logger.error("VOLUMEOPS - Getting JWT token...")
    unless username && password && hostname && url
      Rails.logger.error("VOLUMEOPS - Getting JWT token... invalid inputs")
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
    Rails.logger.error("VOLUMEOPS - Getting JWT token... done")
    post
  end

  def data(token, hostname, url, from_date, to_date)
    unless token && hostname && url
      raise Exception, 'invalid input'
      Rails.logger.error("VOLUMEOPS - Getting JWT data... invalid inputs")
    end

    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.options[:timeout] = 15
      f.adapter Faraday.default_adapter
    end

    response = connection.get do |req|
      req.url hostname + url + "&min_releasedate=#{from_date}&max_releasedate=#{to_date}"
      req.headers['Authorization'] = 'JWT ' + token
    end

    response_body = JSON.parse(response.body)
    has_next ||= response_body['next']

    Rails.logger.error("VOLUMEOPS - Getting JWT... done")
    { data: response_body['results'], has_next: has_next, next_url: response_body['next'], status: response.status, count: response_body['count'] }
  rescue JSON::ParserError => e
    Rails.logger.error("VOLUMEOPS - Getting JWT... failed")
    Rails.logger.error "Can't parse JSON result. Probably an Application Error 500 on VO side"
    redis = Redis.new(url: Figaro.env.redis_url!)
    redis.set(:application_error, Time.zone.now)

    raise e
  end
end
