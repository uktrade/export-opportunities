web: bundle exec rake cf:on_first_instance db:migrate && bundle exec puma -p ${PORT:-3000}
app: cp -r /workspace/db-copy/* /workspace/db/ && bundle exec rake cf:on_first_instance db:migrate && bundle exec rails assets:precompile && bundle exec puma -p ${PORT:-3000}
worker: bin/start-stunnel bundle exec sidekiq -C config/sidekiq.yml
