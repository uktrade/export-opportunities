module DirectoryApiClient
  extend self

  def get(path, session_id='')
    conn = Faraday.new(url: Figaro.env.DIRECTORY_API_DOMAIN)
    response = conn.get do |request|
      request.url path
      request.headers['User-agent'] = "EXPORT-DIRECTORY-API-CLIENT/#{Figaro.env.DIRECTORY_API_VERSION}"
      request.headers['Content-Type'] = 'text/plain'
      request.headers['X-Signature'] = get_header(path)
      request.body = ''
      request.headers['Authorization'] = "SSO_SESSION_ID #{session_id}"
    end
  end

  def get_header(path)
    Hawk::Client.build_authorization_header(
      credentials: {
        id: Figaro.env.DIRECTORY_API_SENDER_ID,
        key: Figaro.env.DIRECTORY_API_SECRET,
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

  def private_company_data(sso_session_cookie)
    request = DirectoryApiClient.get('/supplier/company/', sso_session_cookie)
    if request.status == 200
      JSON.parse(request.body)
    else
      nil
    end
  end

end
