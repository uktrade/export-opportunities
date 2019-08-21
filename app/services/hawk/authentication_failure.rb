module Hawk
  class AuthenticationFailure
    attr_reader :key, :message
    def initialize(key, message, options = {})
      @key = key
      @message = message
      @options = options
    end

    def header
      timestamp = Time.now.to_i
      if @options[:credentials]
        timestamp_mac = Crypto.ts_mac(ts: timestamp, credentials: @options[:credentials]).to_s
        Rails.logger.error("Hawk authorization failed. Error: #{message}")
        %(Hawk ts="#{timestamp}", tsm="#{timestamp_mac}", error="#{message}")
      else
        Rails.logger.error("Hawk authorization failed. Error: #{message}")
        %(Hawk error="#{message}")
      end
    end
  end
end
