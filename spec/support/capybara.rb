require 'capybara/poltergeist'

# Note, phantomjs uses this solution
# https://github.com/teampoltergeist/poltergeist/issues/539
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--load-images=false'], phantomjs: Phantomjs.path)
end
Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = true

Capybara.server_port = CAPYBARA_SERVER_PORT # defined in environments/test.rb

module Capybara
  class Session
    def has_flash_message?(message)
      has_css?('div.flash', text: message)
    end
  end
end
