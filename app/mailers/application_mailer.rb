require 'stringex/unidecoder'
require 'stringex/core_ext'
require 'yaml'

class ApplicationMailer < ActionMailer::Base
  after_action :subject_to_ascii!
  layout 'email'

  default from: Figaro.env.mailer_from_address!

  def subject_to_ascii!
    message.subject = message.subject.to_ascii if message.subject
  end

  # Returns content provided by .yml files in app/content folder.
  # Intended use is to keep content separated from the view code.
  # Should make it easier to switch later to CMS-style content editing.
  # Note: Rails may already provide a similar service for multiple
  # language support, so this mechanism might be replaced by that
  # at some point in the furture.
  def get_content(file)
    YAML.load_file('app/content/' + file)
  end
end
