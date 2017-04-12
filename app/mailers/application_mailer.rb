require 'stringex/unidecoder'
require 'stringex/core_ext'

class ApplicationMailer < ActionMailer::Base
  after_action :subject_to_ascii!
  layout 'email'

  default from: Figaro.env.mailer_from_address!

  def subject_to_ascii!
    message.subject = message.subject.to_ascii if message.subject
  end
end
