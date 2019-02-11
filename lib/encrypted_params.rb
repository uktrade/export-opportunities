class EncryptedParams
  class << self
    def encrypt(input_hash)
      verifier = ActiveSupport::MessageVerifier.new(encryption_secret)
      verifier.generate(input_hash)
    end

    def decrypt(input_string)
      verifier = ActiveSupport::MessageVerifier.new(encryption_secret)
      verifier.verify(input_string)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      raise CouldNotDecrypt
    end

    private

      def encryption_secret
        Figaro.env.feedback_encryption_secret!
      end
  end

  class CouldNotDecrypt < StandardError; end
end
