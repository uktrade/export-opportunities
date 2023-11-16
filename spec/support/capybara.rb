# frozen_string_literal: true
require 'capybara/poltergeist'

module ShowMeTheCookies
  class Poltergeist
    def initialize(driver)
      @browser = driver.browser
      @driver = driver
    end

    def get_me_the_cookie(name)
      cookie = cookies_hash[name.to_s]
      translate(cookie) unless cookie.nil?
    end

    def get_me_the_cookies
      cookies_hash.values.map(&method(:translate))
    end

    def expire_cookies
      cookies_hash.each do |name, cookie|
        delete_cookie(name) if (cookie.expires rescue nil).nil?
      end
    end

    def delete_cookie(name)
      @browser.remove_cookie(name.to_s)
    end

    def create_cookie(name, value, options)
      # see: https://github.com/jonleighton/poltergeist#manipulating-cookies
      @driver.set_cookie(name, value, options)
    end

  private

    def cookies_hash
      @browser.cookies
    end

    def translate(cookie)
      {
        :name => cookie.name,
        :domain => cookie.domain,
        :value => cookie.value,
        :expires => (cookie.expires rescue nil),
        :path => cookie.path,
        :secure => cookie.secure?,
        :httponly => cookie.httponly?
      }
    end
  end
end

ShowMeTheCookies.register_adapter(:poltergeist, ShowMeTheCookies::Poltergeist)

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    phantomjs_options: ['--load-images=false'],
    timeout: 30
  )
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
