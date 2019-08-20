module Hawk
  module AuthorizationHeader
    extend self

    REQUIRED_OPTIONS = %i[method request_uri host port].freeze
    REQUIRED_CREDENTIAL_MEMBERS = %i[id key algorithm].freeze
    SUPPORTED_ALGORITHMS = %w[sha256 sha1].freeze
    HEADER_PARTS = %i[id ts nonce hash ext mac].freeze

    DEFAULT_TIMESTAMP_SKEW = 60.freeze # plus/minus 60 seconds

    MissingOptionError = Class.new(StandardError)
    InvalidCredentialsError = Class.new(StandardError)
    InvalidAlgorithmError = Class.new(StandardError)

    def build(options, only = nil)
      options[:ts] ||= Time.now.to_i
      options[:nonce] ||= SecureRandom.hex(4)

      check_options(options)

      credentials = options[:credentials]
      check_credentials(credentials)
      check_algorithm(credentials)

      parts = create_parts(options, credentials)

      contruct_header_value(only, parts)
    end

    def authenticate(header, options)
      options = options.dup
      parts = parse(header)
      options.delete(:payload) unless parts[:hash]
      options[:timestamp_skew] ||= DEFAULT_TIMESTAMP_SKEW

      begin
        if options[:server_response]
          credentials = options[:credentials]
          parts[:ts] = options[:ts]
          parts[:nonce] = options[:nonce]
        else
          credentials = get_credentials_and_check_id(options, parts)
          check_ts(options, parts, credentials)
          check_nonce(options, parts)
        end

        check_hash(parts, options, credentials)
        check_mac(options, parts, credentials)
      rescue Hawk::AuthFailureError => e
        return AuthenticationFailure.new(e.part, e.message, e.options)
      end
      credentials
    end

    def parse(header)
      parts = header.sub(/\AHawk\s+/, '').split(/,\s*/)
      parts.each_with_object({}) do |part, memo|
        next memo unless part =~ /([a-z]+)=(['"])([^\2]+)\2/

        key = Regexp.last_match(1)
        val = Regexp.last_match(3)
        memo[key.to_sym] = val
      end
    end

    private

      def check_options(options)
        REQUIRED_OPTIONS.each do |key|
          unless options.key?(key)
            raise MissingOptionError, "#{key.inspect} is missing!"
          end
        end
      end

      def check_credentials(credentials)
        REQUIRED_CREDENTIAL_MEMBERS.each do |key|
          unless credentials.key?(key)
            raise InvalidCredentialsError, "#{key.inspect} is missing!"
          end
        end
      end

      def check_algorithm(credentials)
        unless SUPPORTED_ALGORITHMS.include?(credentials[:algorithm])
          raise InvalidAlgorithmError, "#{credentials[:algorithm].inspect} is not a supported algorithm! Use one of the following: #{SUPPORTED_ALGORITHMS.join(', ')}"
        end
      end

      def create_parts(options, credentials)
        hash = Crypto.hash(options).to_s
        mac = Crypto.mac(options)
        parts = {
          id: credentials[:id],
          ts: options[:ts],
          nonce: options[:nonce],
          mac: mac.to_s,
        }
        parts[:hash] = hash if options.key?(:payload) && !options[:payload].nil?
        parts[:ext] = options[:ext] if options.key?(:ext)
        parts
      end

      def contruct_header_value(only, parts)
        'Hawk ' << (only || HEADER_PARTS).each_with_object([]) do |key, memo|
          next memo unless parts.key?(key)

          memo << %(#{key}="#{parts[key]}")
        end.join(', ')
      end

      def build_mac_opts(options, parts, credentials)
        options.merge(
          credentials: credentials,
          ts: parts[:ts],
          nonce: parts[:nonce],
          ext: parts[:ext],
          app: options[:app] || parts[:app],
          dlg: options[:dlg] || parts[:dlg]
        )
      end

      def check_hash(parts, options, credentials)
        expected_hash = parts[:hash] ? Crypto.hash(options.merge(credentials: credentials)) : nil
        if expected_hash && expected_hash.to_s != parts[:hash]
          raise Hawk::AuthFailureError.new(:hash, "Invalid hash. #{expected_hash.normalized_string}")
        end
      end

      def check_mac(options, parts, credentials)
        mac_opts = build_mac_opts(options, parts, credentials)
        expected_mac = Crypto.mac(mac_opts)
        unless expected_mac.eql?(parts[:mac])
          raise Hawk::AuthFailureError.new(:mac, "Invalid mac. #{expected_mac.normalized_string}")
        end
      end

      def get_credentials_and_check_id(options, parts)
        unless options[:credentials_lookup].respond_to?(:call) && (credentials = options[:credentials_lookup].call(parts[:id]))
          raise Hawk::AuthFailureError.new(:id, 'Unidentified id')
        end

        credentials
      end

      def check_ts(options, parts, credentials)
        now = Time.now.to_i
        if (now - parts[:ts].to_i > options[:timestamp_skew]) || (parts[:ts].to_i - now > options[:timestamp_skew])
          # Stale timestamp
          raise Hawk::AuthFailureError.new(:ts, 'Stale ts', credentials: credentials)
        end
      end

      def check_nonce(options, parts)
        unless parts[:nonce]
          raise Hawk::AuthFailureError.new(:nonce, 'Missing nonce')
        end

        if options[:nonce_lookup].respond_to?(:call) && options[:nonce_lookup].call(parts[:nonce])
          # Replay
          raise Hawk::AuthFailureError.new(:nonce, 'Invalid nonce')
        end
      end
  end
end
