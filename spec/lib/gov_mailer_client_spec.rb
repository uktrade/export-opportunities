require 'rails_helper'

RSpec.describe GovMailerClient do
  describe 'send a mail using the GOV notify client' do
    it 'sends a mail using gov notify' do
      skip('need to add email to gov notify whitelist to be able to send')
      GovMailerClient.new.send_email('email@example.com')
    end
  end
end
