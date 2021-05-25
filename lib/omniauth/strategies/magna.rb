require 'omniauth'

module OmniAuth
  module Strategies
    class Magna
      include OmniAuth::Strategy

      option :token_params,
             redirect_uri: "#{Figaro.env.domain}/export-opportunities/users/auth/magna/callback"

      def request_phase
        redirect "#{Figaro.env.MAGNA_SSO_LOGIN}?next=#{callback_path}"
      end
    end
  end
end
