# Per https://github.com/mhfs/devise-async#troubleshooting
Devise::Async.setup do |config|
  config.backend = :sidekiq
  config.queue   = :mailers # Same as ActionMailer's queue
end
