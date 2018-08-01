module SingleSignOnHelpers
  def mock_sso_with(email:, uid: '123456')
    if Figaro.env.bypass_sso?
      provider = :developer
    else
      provider = :exporting_is_great
    end

    OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new(
      provider: 'exporting_is_great',
      uid: uid.to_s,
      info: {
        email: email,
        id: uid.to_s,
      }
    )
  end
end
