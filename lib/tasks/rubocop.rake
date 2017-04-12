begin
  require 'rubocop/rake_task'
rescue LoadError
  puts 'Skipping RuboCop, gem/library is unloadable'
else
  RuboCop::RakeTask.new
  task default: :rubocop
end
