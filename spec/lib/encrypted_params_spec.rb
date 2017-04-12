require 'rails_helper'

RSpec.describe EncryptedParams do
  describe '#encrypt' do
    it 'encrypts a hash and returns an encrypted string' do
      params_hash = { id: 123, some_param: 456 }

      encrypted_string = EncryptedParams.encrypt(params_hash)

      expect(encrypted_string).to be_a String
    end
  end

  describe '#encrypt and #decrypt' do
    it 'can encrypt and decrypt a params hash' do
      expected_params_hash = { id: 123, some_param: 456 }
      encrypted_string = EncryptedParams.encrypt(expected_params_hash)

      params_hash = EncryptedParams.decrypt(encrypted_string)

      expect(encrypted_string).not_to eq params_hash
      expect(params_hash).to be_a Hash
      expect(params_hash).to eql expected_params_hash
    end
  end

  describe 'decrypting an invalid string' do
    it 'throws an EncryptedParams::CouldNotDecrypt exception' do
      expect { EncryptedParams.decrypt('aubergine') }.to raise_error(EncryptedParams::CouldNotDecrypt)
    end
  end
end
