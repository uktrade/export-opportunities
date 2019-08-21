module Hawk
  class AuthFailureError < StandardError
    attr_reader :part, :options
    def initialize(part, msg, options = {})
      @part = part
      @options = options
      super(msg)
    end
  end
end
