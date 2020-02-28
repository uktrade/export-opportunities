source 'https://rubygems.org'

ruby '2.5.6'

gem 'rails', '5.2.3'
gem 'bundler'
gem 'puma', '3.12.3'
gem 'pg', '1.1.4'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sidekiq-failures'
gem 'redis', '3.3.3'
gem 'redis-namespace'
gem 'faraday', '0.12.2'
gem 'figaro'
gem 'friendly_id'
gem 'immutable-struct'

gem 'nokogiri', '1.10.4'

# Authentication & authorisation
gem 'devise', '4.7.1'
gem 'devise-async'
gem 'hawk-auth'
gem 'omniauth'
gem 'omniauth-oauth2'
gem 'pundit', require: true

# Rendering
gem 'haml'
gem 'jbuilder'
gem 'sdoc'

# Search
gem 'pg_search'
gem 'kaminari'
gem 'elasticsearch-rails', '5.1.0'
gem 'elasticsearch-model', '5.1.0'
gem 'devise_security_extension', git: 'https://github.com/phatworx/devise_security_extension.git'

# Styling
gem 'bourbon'
gem 'neat', '1.8.0'
gem 'autoprefixer-rails'
gem 'normalize-scss'
gem 'sass-rails'
gem 'export_components', '2.2.2', git: 'https://github.com/uktrade/export_components.git'

# Javascript
gem 'jquery-rails'
gem 'ckeditor'

# Ruby tools
gem 'stringex', require: false
gem 'addressable'

# ActiveRecord tools
gem 'hairtrigger', '0.2.22'
gem 'active_record_union'

# Parsing JSON
gem 'yajl-ruby', '>= 1.3.1'

# Developer tools
gem 'pry-rails'
gem 'premailer-rails'
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem 'paper_trail', '9.2.0'

# aws sdk for s3 storage of post-user communications
gem 'aws-sdk'

# Monitoring
gem 'sentry-raven'

# file uploader
gem 'carrierwave', '1.3.1'

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
  gem 'rubocop', '~> 0.77.0', require: false
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
  gem 'webmock', '3.4.2'
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
  gem 'show_me_the_cookies'
  gem 'rails-controller-testing'
  gem 'mock_redis'
end

group :production do
  gem 'rails_12factor'
end
