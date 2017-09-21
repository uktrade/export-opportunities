web: bundle exec rake db:migrate && bundle exec puma -p ${PORT:-3000}
worker: stunnel bundle exec sidekiq -C config/sidekiq.yml
