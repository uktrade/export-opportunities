source 'https://rubygems.org'

ruby '2.3.3'

gem 'rails', '< 5'
gem 'puma'
gem 'pg'
gem 'sidekiq'
gem 'sidekiq-cron-tasks'
gem 'redis'
gem 'redis-namespace'
gem 'faraday'
gem 'figaro'
gem 'friendly_id'
gem 'immutable-struct'

# Authentication & authorisation
gem 'devise'
gem 'devise-async'
gem 'omniauth'
gem 'omniauth-oauth2', '~> 1.3.1'
gem 'pundit', require: true

# Rendering
gem 'haml'
gem 'jbuilder'
gem 'sdoc'

# Search
gem 'pg_search'
gem 'kaminari'
gem 'faraday_middleware-aws-signers-v4'
gem 'elasticsearch-rails', '0.1.9'
gem 'elasticsearch-model', '0.1.9'

# Styling
gem 'bourbon'
gem 'neat'
gem 'autoprefixer-rails'
gem 'normalize-scss'
gem 'sass-rails'

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
gem 'yajl-ruby'

# Developer tools
gem 'pry-rails'
gem 'premailer-rails'
gem 'flipper'
gem 'flipper-redis'
gem 'flipper-ui'
gem 'paper_trail'

# Monitoring
gem 'sentry-raven'

group :development, :test do
  gem 'byebug'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'bullet'
end

group :development do
  gem 'web-console'
  gem 'rubocop', require: false
end

group :test do
  gem 'capybara', require: false
  gem 'capybara-email', require: false
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
  gem 'test_after_commit'
  gem 'elasticsearch-extensions'
end

group :production do
  gem 'rails_12factor'
end
