# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class StaffSso < OmniAuth::Strategies::OAuth2 # :nodoc:
      option :name, 'staff_sso'

      SSO_PROVIDER = Figaro.env.STAFF_SSO_PROVIDER

      option :client_options,
             site: SSO_PROVIDER,
             authorize_url: "#{SSO_PROVIDER}/o/authorize/",
             token_url: "#{SSO_PROVIDER}/o/token/"

      def request_phase
        super
      end

      uid do
        raw_info['user_id']
      end

      info do
        {
          first_name: raw_info['first_name'],
          last_name: raw_info['last_name'],
          email: raw_info['email'].downcase
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/user/me/').parsed
      end

      def callback_url
        Figaro.env.STAFF_SSO_CALLBACK_URL
      end
    end
  end
end
