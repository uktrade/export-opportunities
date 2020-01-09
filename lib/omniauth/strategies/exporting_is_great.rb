require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class ExportingIsGreat < OmniAuth::Strategies::OAuth2
      option :name, 'exporting_is_great'

      option :client_options,
             site: Figaro.env.sso_endpoint_base_uri,
             authorize_url: 'oauth2/authorize/',
             token_url: 'oauth2/token/'

      option :token_params,
             redirect_uri: "#{Figaro.env.domain}/export-opportunities/users/auth/exporting_is_great/callback"

      uid { raw_info['id'] }

      info do
        { email: raw_info['email'] }
      end

      def request_phase
        redirect client.auth_code.authorize_url(
          { 'export-opportunity-intent': 'true', redirect_uri: callback_url }
          .merge(options.authorize_params)
        )
      end

      extra do
        raw_info
      end

      def raw_info
        @raw_info ||= access_token.get('oauth2/user-profile/v1/').parsed
      end
    end
  end
end
