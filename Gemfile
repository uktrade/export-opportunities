source 'https://rubygems.org'

ruby '3.2.2'

gem 'matrix', '0.4.2'
gem 'rails', '6.1.7.8'
gem 'bundler'
gem 'puma', '5.6.9'
gem 'pg', '1.5.4'
gem 'sidekiq', '7.1.3'
gem 'sidekiq-cron', '1.9.1'
gem 'sidekiq-failures', '1.0.1'
gem 'redis', '5.2.0'
gem 'redis-namespace', '1.10.0'
gem 'faraday', '1.0.1'
gem 'figaro'
gem 'friendly_id'
gem 'immutable-struct'

gem 'nokogiri', '>= 1.16.7'

# Log formatting
gem "json_tagged_logger"
gem "lograge"

# Authentication & authorisation
gem 'devise'
gem 'devise-async'
gem 'hawk-auth'
gem 'omniauth', '2.0.3'
gem 'omniauth-oauth2', '1.7.1'
gem 'omniauth-rails_csrf_protection'
gem 'pundit', require: true

# Rendering
gem 'haml'
gem 'jbuilder'
gem 'sdoc'

# Search
gem 'pg_search'
gem 'kaminari', '>= 1.2.1'
gem 'elasticsearch', '7.9.0'
gem 'elasticsearch-rails', '7.1.1'
gem 'elasticsearch-model', '7.1.1'
gem 'devise-security', '0.14.3'

# Styling
gem 'bourbon'
gem 'neat'
gem 'autoprefixer-rails'
gem 'normalize-scss'
gem 'sass-rails'

# Javascript
gem 'jquery-rails'
# gem 'ckeditor'

# Ruby tools
gem 'stringex', require: false
gem 'addressable'

# ActiveRecord tools
gem 'hairtrigger', '1.0.0'
gem 'active_record_union'

# JSON
gem 'yajl-ruby', '>= 1.4.3'
gem 'jmespath', '1.6.1'

# Developer tools
gem 'pry-rails'
gem 'premailer-rails'
gem 'flipper', '0.26.0'
gem 'flipper-redis', '0.26.0'
gem 'flipper-ui', '0.26.0'
gem 'paper_trail', '12.3.0'

# aws sdk for s3 storage of post-user communications
gem 'aws-sdk'

# Monitoring
gem 'sentry-raven', '3.0.0'

# rest client for antivirus scanning
gem 'rest-client'

# zipping for email attachments over 10MB
gem 'rubyzip', '~> 1.3.0'

# JSON Web Tokens for Volume Opps
gem 'jwt'

# caching
gem 'actionpack-page_caching'

# Sentence splitting
gem 'pragmatic_segmenter'

# Govt Notify service API client
gem 'notifications-ruby-client'

group :development, :test do
  gem 'byebug'
  gem 'faker'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'bullet'
  gem 'uglifier'
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :development do
  gem 'web-console'
  gem 'rubocop', '~> 1.0.0', require: false
  gem 'rubocop-faker'
  gem 'listen'
end

group :test do
  gem 'capybara', require: false
  gem 'capybara-email', require: false
  gem 'capybara-screenshot'
  gem 'fuubar'
  gem 'shoulda-matchers', require: false
  gem 'rspec-sidekiq'
  gem 'timecop'
  gem 'webmock', '3.19.1'
  gem 'rspec-rails'
  gem 'rspec-mocks'
  gem 'rspec-collection_matchers'
  gem 'rspec_junit_formatter'
  gem 'pundit-matchers'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'poltergeist'
  gem 'simplecov'
  gem 'vcr'
  gem 'elasticsearch-extensions'
  gem 'show_me_the_cookies', '6.0.0'
  gem 'rails-controller-testing'
  gem 'mock_redis'
end
