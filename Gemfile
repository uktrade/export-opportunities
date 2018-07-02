source 'https://rubygems.org'

ruby '2.4.3'

gem 'rails', '5.1.4'
gem 'bundler', '1.16.1'
gem 'puma', '3.8.0'
gem 'pg', '0.21.0'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sidekiq-failures'
gem 'redis', '3.3.3'
gem 'redis-namespace'
gem 'faraday'
gem 'figaro'
gem 'friendly_id'
gem 'immutable-struct'

gem 'nokogiri', '1.8.2'

# Authentication & authorisation
gem 'devise', '4.3.0'
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
gem 'faraday_middleware-aws-signers-v4'
gem 'elasticsearch-rails'
gem 'elasticsearch-model'
gem 'devise_security_extension', git: 'https://github.com/phatworx/devise_security_extension.git'

# Styling
gem 'bourbon'
gem 'neat', '1.8.0'
gem 'autoprefixer-rails'
gem 'normalize-scss'
gem 'sass-rails'
gem 'export_components', '0.1.0', git: 'https://github.com/uktrade/export_components.git'

# Javascript
gem 'jquery-rails'
gem 'ckeditor'

# Ruby tools
gem 'stringex', require: false
gem 'addressable'

# ActiveRecord tools
gem 'hairtrigger'
gem 'active_record_union'

# Parsing JSON
gem 'yajl-ruby', '>= 1.3.1'

# Developer tools
gem 'pry-rails'
gem 'premailer-rails'
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem 'paper_trail'

# aws sdk for s3 storage of post-user communications
gem 'aws-sdk'

# Monitoring
gem 'sentry-raven'

# file uploader
gem 'carrierwave'

# rest client for antivirus scanning
gem 'rest-client'

# zipping for email attachments over 10MB
gem 'rubyzip'

# JSON Web Tokens for Volume Opps
gem 'jwt'

group :development, :test do
  gem 'byebug'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'bullet'
  gem 'uglifier'
end

group :development do
  gem 'web-console'
  gem 'rubocop', '~> 0.49.0', require: false
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

  gem 'webmock'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'
  gem 'rspec_junit_formatter'
  gem 'pundit-matchers'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'launchy'
  gem 'poltergeist'
  gem 'simplecov'
  gem 'vcr'
  gem 'elasticsearch-extensions'
  gem 'show_me_the_cookies'
  gem 'rails-controller-testing'
end

group :production do
  gem 'rails_12factor'
end
