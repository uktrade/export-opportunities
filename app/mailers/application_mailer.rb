require 'stringex/unidecoder'
require 'stringex/core_ext'

class ApplicationMailer < ActionMailer::Base
  after_action :subject_to_ascii!
  layout 'email'

  default from: ENV.fetch('MAILER_FROM_ADDRESS')

  def subject_to_ascii!
    message.subject = message.subject.to_ascii if message.subject
  end
end
