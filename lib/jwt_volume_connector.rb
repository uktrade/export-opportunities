class JwtVolumeConnector
  def call(username, password, hostname, url)
    token = self.token(username, password, hostname, url)
    data(token, hostname, url)
  end

  def token(username, password, hostname, url)
    raise Exception, 'invalid input' unless username && password && hostname && url
    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.adapter  Faraday.default_adapter
    end

    connection.post do |req|
      req.url hostname + url
      req.headers['Content-Type'] = 'application/json'
      req.body = "{ \"username\": \"#{username}\", \"password\": \"#{password}\" }"
    end
  end

  def data(token, hostname, url)
    raise Exception, 'invalid input' unless token && hostname && url
    connection = Faraday.new(url: hostname) do |f|
      f.response :logger
      f.adapter  Faraday.default_adapter
    end

    response = connection.get do |req|
      req.url hostname + url
      req.headers['Authorization'] = 'JWT ' + token
    end

    response_body = JSON.parse(response.body)
    has_next ||= response_body['next']

    { data: response_body['results'], has_next: has_next, next_url: response_body['next'], status: response.status, count: response_body['count'] }
  end
end
