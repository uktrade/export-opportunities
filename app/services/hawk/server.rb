module Hawk
  module Server
    extend self

    def authenticate(authorization_header, options)
      Hawk::AuthorizationHeader.authenticate(authorization_header, options)
    end

    def authenticate_bewit(encoded_bewit, options)
      bewit = Crypto::Bewit.decode(encoded_bewit)

      begin
        credentials = get_credentials_and_check_id(options, bewit)

        check_time(bewit)

        expected_bewit = build_bewit(bewit, options, credentials)

        unless expected_bewit.eql?(bewit)
          if /\Ahttp/.match?(options[:request_uri].to_s)
            return authenticate_bewit(encoded_bewit, options.merge(
                                                       request_uri: options[:request_uri].sub(%r{\Ahttps?://[^/]+}, '')
                                                     ))
          else
            raise Hawk::AuthFailureError.new(:bewit, "Invalid signature #{expected_bewit.mac.normalized_string}")
          end
        end
      rescue Hawk::AuthFailureError => e
        return AuthenticationFailure.new(e.part, e.message, e.options)
      end

      credentials
    end

    def build_authorization_header(options)
      options[:type] = 'response'
      Hawk::AuthorizationHeader.build(options, %i[hash ext mac])
    end

    def build_tsm_header(options)
      Hawk::TimestampMacHeader.build(options)
    end

    private

      def remove_bewit_param_from_path(path)
        path, query = path.split('?')
        return path unless query

        query, fragment = query.split('#')
        query = query.split('&').reject { |i| i.starts_with? 'bewit=' }.join('&')
        path << "?#{query}" if query != ''
        path << fragment.to_s if fragment
        path
      end

      def get_credentials_and_check_id(options, bewit)
        unless options[:credentials_lookup].respond_to?(:call) && (credentials = options[:credentials_lookup].call(bewit.id))
          raise Hawk::AuthFailureError.new(:id, 'Unidentified id')
        end

        credentials
      end

      def check_time(bewit)
        if Time.at(bewit.ts.to_i).in_time_zone < Time.now.in_time_zone
          raise Hawk::AuthFailureError.new(:ts, 'Stale timestamp')
        end
      end

      def build_bewit(bewit, options, credentials)
        Crypto.bewit(
          credentials: credentials,
          host: options[:host],
          request_uri: remove_bewit_param_from_path(options[:request_uri]),
          port: options[:port],
          method: options[:method],
          ts: bewit.ts,
          ext: bewit.ext
        )
      end
  end
end
