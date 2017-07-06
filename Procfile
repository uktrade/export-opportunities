web: rake db:migrate && bin/start-stunnel bundle exec puma -p ${PORT:-3000}
worker: bin/start-stunnel bundle exec sidekiq -C config/sidekiq.yml
