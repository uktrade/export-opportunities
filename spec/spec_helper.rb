RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.profile_examples = nil
  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = 'spec/examples.txt'
end

# Add the root of the project to the load path so that we can
# explicitly load dependent files in isolated specs
$LOAD_PATH << File.expand_path('../../', __FILE__)
