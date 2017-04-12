module SingleSignOnHelpers
  def mock_sso_with(email:, uid: '123456')
    OmniAuth.config.mock_auth[:exporting_is_great] = OmniAuth::AuthHash.new(
      provider: 'exporting_is_great',
      uid: uid.to_s,
      info: {
        email: email,
        id: uid.to_s,
      }
    )
  end
end
