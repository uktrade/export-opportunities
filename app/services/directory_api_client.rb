module DirectoryApiClient
  extend self

  def request(method, path)
    conn = Faraday.new(url: Figaro.env.DIRECTORY_API_DOMAIN)
    response = conn.get do |request|
      request.url path
      request.headers['User-agent'] = "EXPORT-DIRECTORY-API-CLIENT/#{Figaro.env.DIRECTORY_API_VERSION}"
      request.headers['Content-Type'] = 'text/plain'
      request.headers['X-Signature'] = get_header(path)
      request.body = ''
      request.headers['Authorization'] = "SSO_SESSION_ID #{'cUthbm1pVUJ5cStVWmdIZHZiTzdGTCtQRlFXY2ZWalJvYTc0VkhlVzFtOE0xM0xBTC9hOWpiMHNHd3hwd0ZuVVh5L1NIU0FDRmVkSVRDODlsQzVKY0ZJZ1ZMU3ZITk5XeXlyRXVjK2FhbVpKSURBdmd1aW1WOEc0NFhTMGFsQjF0bkh0T3pCR3QrNWtTTVVCcGxsMWNiL1NKNlY0c1JhdmhsVHQxUDh3d2U0aml6OEI1MXpEc0NsU1FpdU5ZOGtGcVFWbzRPY0xTK2t3elh5TUdQVzlwcnV4NUQ5RUVWQTVDK2pUSGpvMGtHYmp3NWRXVTIzQ09uTVFHWlR3SlpUZTZ5Wm9IMHZXblFzYlBPNkNCNFdxbE01R2NxZDQ3dDExUmpSVTFhbjl0QmRCTThtVmtyc3ljZ3grQWNIOVladEJ6Nkt1clRlNUJHSFlySUZ1dE9JZTVrL3ZkS3VnMXgzNmR0dExNSTZXNVhjeStmQ0QxVlZ0U1NYeThYVFUrK0VxLS1qVS92akl6a1dwclVnSktRK1R4Qkt3PT0%3D--cec1dc0eba4e62482e7e995e005782b32eaff32f'}"
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

end
