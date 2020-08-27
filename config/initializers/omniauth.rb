# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger

module OmniAuth
  module Strategies # :nodoc:
    autoload :ExportingIsGreat,
             Rails.root.join(
               'lib', 'omniauth', 'strategies', 'exporting_is_great'
             )

    autoload :StaffSso,
             Rails.root.join(
               'lib', 'omniauth', 'strategies', 'staff_sso'
             )
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer, fields: [:email] if Figaro.env.bypass_sso?

  provider :exporting_is_great,
           Figaro.env.sso_client_id,
           Figaro.env.sso_client_secret,
           scope: 'profile',
           provider_ignores_state: true

  provider :staff_sso,
           Figaro.env.STAFF_SSO_CLIENT_ID,
           Figaro.env.STAFF_SSO_CLIENT_SECRET,
           request_path: '/export-opportunities/admin/auth/staff_sso',
           callback_path: '/export-opportunities/admin/auth/staff_sso/callback'
end
