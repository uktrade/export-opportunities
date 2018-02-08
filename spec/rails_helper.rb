require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'sidekiq/testing'
require 'webmock/rspec'

require 'support/capybara'
require 'support/controller_macros'
require 'support/database_cleaner'
require 'support/factory_girl'
require 'support/devise'
require 'support/shoulda_matchers'
require 'support/wait_for_ajax'
require 'support/single_sign_on_helpers'
require 'support/appear_before'
require 'support/webmock'
require 'support/elastic_search'
require 'support/request_spec_helper'
require 'capybara-screenshot/rspec'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.extend ControllerMacros, type: :controller
  config.include ActiveSupport::Testing::TimeHelpers
  config.include WaitForAjax, type: :feature
  config.include SingleSignOnHelpers, type: :feature
  config.include SingleSignOnHelpers, type: :controller
  config.include SingleSignOnHelpers, type: :request
  config.include RequestSpecHelper, type: :request
  config.include ActionView::Helpers::TranslationHelper

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.render_views = true
  config.infer_spec_type_from_file_location!

  config.before(:all) do
    # Where any models using Devise are 'async' this causes them to behave as though they are not, and you'll be able to tests emails etc.
    Devise::Async.enabled = false

    Faker::Config.locale = 'en-GB'
  end

  config.before(:each) do |example|
    Sidekiq::Worker.clear_all
    if example.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!
    elsif example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!
    elsif example.metadata[:type] == :acceptance
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end

    ExportOpportunities.flipper.features.map(&:remove)
  end

  config.after(:each) do |_example|
    OmniAuth.config.mock_auth[:exporting_is_great] = nil
  end

  config.include ShowMeTheCookies

  config.before(:each, js: true) do
    create_cookie('UPDATE-JANUARY-2018-ACCEPTED', true)
  end
end

RSpec::Sidekiq.configure do |config|
  config.clear_all_enqueued_jobs = true
  config.enable_terminal_colours = true
  config.warn_when_jobs_not_processed_by_sidekiq = false
end

OmniAuth.config.test_mode = true
