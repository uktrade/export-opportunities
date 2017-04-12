require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe ApplicationMailer, type: :mailer do
  class VanillaApplicationMailer < ApplicationMailer
    def send_an_email(args)
      mail(args.merge(body: 'test email body', to: 'test@test.com'))
    end
  end

  describe 'converting subject lines to ASCII' do
    it 'handles special characters' do
      VanillaApplicationMailer.send_an_email(subject: "People's Republic of föobårbàż — €100 worth of saké wanted").deliver_later!
      last_delivery = ActionMailer::Base.deliveries.last
      expect(last_delivery.subject).to eq "People's Republic of foobarbaz --- EU100 worth of sake wanted"
    end
  end
end
