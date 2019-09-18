module DirectoryApiClient
  module_function

  def directory_api_get(path, session_id = '')
    conn = Faraday.new(url: Figaro.env.DIRECTORY_API_DOMAIN)
    conn.get do |request|
      request.url path
      request.headers['User-agent'] = "EXPORT-DIRECTORY-API-CLIENT/#{Figaro.env.DIRECTORY_API_VERSION}"
      request.headers['Content-Type'] = 'text/plain'
      request.headers['X-Signature'] = get_header(
        path,
        Figaro.env.DIRECTORY_API_SENDER_ID,
        Figaro.env.DIRECTORY_API_SECRET
      )
      request.body = ''
      request.headers['Authorization'] = "SSO_SESSION_ID #{session_id}"
    end
  end

  def directory_sso_api_get(path)
    conn = Faraday.new(url: Figaro.env.DIRECTORY_SSO_API_DOMAIN)
    conn.get do |request|
      request.url path
      request.headers['User-agent'] = "EXPORT-DIRECTORY-API-CLIENT/#{Figaro.env.DIRECTORY_SSO_API_VERSION}"
      request.headers['X-Signature'] = get_header(
        path,
        Figaro.env.DIRECTORY_SSO_API_SENDER_ID,
        Figaro.env.DIRECTORY_SSO_API_SECRET
      )
      request.headers['Content-Type'] = 'text/plain'
      request.body = ''
    end
  end

  def get_header(path, id, secret)
    Hawk::Client.build_authorization_header(
      credentials: {
        id: id,
        key: secret,
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

  def private_company_data(sso_session)
    request = directory_api_get('/supplier/company/', sso_session)
    JSON.parse(request.body) if request.status == 200
  end

  def user_data(sso_session)
    request = directory_sso_api_get("/api/v1/session-user/?session_key=#{sso_session}")
    JSON.parse(request.body) if request.status == 200
  end
end
