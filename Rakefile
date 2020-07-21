# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

desc 'Switch logger to stdout'
task to_stdout: [:environment] do
  Rails.logger = Logger.new(STDOUT)
end

namespace :cf do
  desc 'Only run on the first application instance'
  task :on_first_instance do
    instance_index = if ENV['VCAP_APPLICATION'] && JSON.parse(ENV['VCAP_APPLICATION'])
                       JSON.parse(ENV['VCAP_APPLICATION'])['instance_index']
                     end
    exit(0) unless instance_index.zero?
  end
end

Rails.application.load_tasks
