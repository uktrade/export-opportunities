module DirectorySsoApiClient
  module_function

  def get(path)
    conn = Faraday.new(url: Figaro.env.DIRECTORY_SSO_API_DOMAIN)
    conn.get do |request|
      request.url path
      request.headers['User-agent'] = "EXPORT-DIRECTORY-API-CLIENT/#{Figaro.env.DIRECTORY_SSO_API_VERSION}"
      request.headers['X-Signature'] = get_header(path)
      request.headers['Content-Type'] = 'text/plain'
      request.body = ''
    end
  end

  def get_header(path)
    Hawk::Client.build_authorization_header(
      credentials: {
        id: Figaro.env.DIRECTORY_SSO_API_SENDER_ID,
        key: Figaro.env.DIRECTORY_SSO_API_SECRET,
        algorithm: 'sha256',
      },
      method: 'GET',
      host: '',
      port: 'None',
      request_uri: path,
      content_type: 'text/plain',
      payload: ''
    )
  end

  def user_data(sso_session_cookie)
    request = DirectorySsoApiClient.get("/api/v1/session-user/?session_key=#{sso_session_cookie}")
    if request.status == 200
      JSON.parse(request.body)
    end
  end
end
