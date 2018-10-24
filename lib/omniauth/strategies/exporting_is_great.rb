require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class ExportingIsGreat < OmniAuth::Strategies::OAuth2
      option :name, 'exporting_is_great'

      option :client_options,
        site: Figaro.env.sso_endpoint_base_uri,
        authorize_url: "#{Figaro.env.SSO_ENDPOINT_SSO_APPEND}/oauth2/authorize/",
        token_url: "#{Figaro.env.SSO_ENDPOINT_SSO_APPEND}/oauth2/token/"

      option :token_params,
        redirect_uri: "#{Figaro.env.domain}/users/auth/exporting_is_great/callback"

      uid { raw_info['id'] }

      info do
        { email: raw_info['email'] }
      end

      extra do
        raw_info
      end

      def raw_info
        @raw_info ||= access_token.get("#{Figaro.env.SSO_ENDPOINT_SSO_APPEND}/oauth2/user-profile/v1/").parsed
      end
    end
  end
end
