tag 'ukti-opportunities'
daemonize false

port Integer(ENV.fetch('PORT', 3000))
environment ENV['RAILS_ENV'] || 'development'

thread_count = Integer(ENV.fetch('THREADS', 5))
threads thread_count, thread_count

workers Integer(ENV.fetch('PROCESSES', 1))

preload_app!

quiet

on_worker_boot do
  require 'active_record'
  begin
    ActiveRecord::Base.connection.disconnect!
  rescue
    ActiveRecord::ConnectionNotEstablished
  end
  ActiveSupport.on_load(:rails) do
    require 'figaro'
    Figaro.load

    cwd = File.dirname(__FILE__) + '/..'
    db = ENV['DATABASE_URL'] || YAML.load_file("#{cwd}/config/database.yml")[ENV['RAILS_ENV']]
    ActiveRecord::Base.establish_connection(db)
  end
end
