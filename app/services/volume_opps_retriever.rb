class VolumeOppsRetriever
  def call
    username = Figaro.env.OO_USERNAME!
    password = Figaro.env.OO_PASSWORD!
    hostname = Figaro.env.OO_HOSTNAME!
    data_endpoint = Figaro.env.OO_DATA_ENDPOINT!
    token_endpoint = Figaro.env.OO_TOKEN_ENDPOINT!

    token_response = JwtVolumeConnector.new.token(username, password, hostname, token_endpoint)
    res = JwtVolumeConnector.new.data(JSON.parse(token_response.body)['token'], hostname, data_endpoint)

    while res[:has_next]
      # store data from page
      res[:data].each do |opportunity|
        pp opportunity
      end
      res = JwtVolumeConnector.new.data(JSON.parse(token_response.body)['token'], res[:next_url], '')
    end
  end
end
