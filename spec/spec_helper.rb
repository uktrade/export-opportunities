require 'vcr'
require 'elasticsearch/extensions/test/cluster'

RSpec.configure do |config|
  config.around :each, elasticsearch: true do |example|
    [Opportunity, Subscription].each do |model|
      model.__elasticsearch__.create_index!(force: true)
      model.__elasticsearch__.refresh_index! if model.__elasticsearch__.index_exists? index: model.__elasticsearch__.index_name
    end
    example.run
    [Opportunity, Subscription].each do |model|
      model.__elasticsearch__.client.indices.delete index: model.index_name
    end
  end

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

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'elasticsearch_cassettes'
  c.ignore_request do |req|
    URI(req.uri).port = 2323
  end
end

# Add the root of the project to the load path so that we can
# explicitly load dependent files in isolated specs
$LOAD_PATH << File.expand_path('../../', __FILE__)

def create_elastic_search_opportunity(result_body = {})
  result = {
    '_index' => 'opportunities',
    '_type' => 'opportunity',
    '_id' => 'f33fc1d7-3c73-4342-8b1b-f922cb3df881',
    '_score' => 1.0,
    '_source' =>
      {
        'title' => 'French sardines required',
        'slug' => 'french-sardines-required',
        'created_at' => '2017-02-16T10:18:31.086Z',
        'updated_at' => '2017-03-02T10:18:31.575Z',
        'status' => 'publish',
        'teaser' => 'Illo illum totam corrupti qui. Voluptatum voluptate non doloremque aut nihil doloribus. Et non quis vero incidunt est.',
        'response_due_on' => '2017-12-02',
        'description' =>
          'Illo illum totam corrupti qui. Voluptatum voluptate non doloremque aut nihil doloribus. Et non quis vero incidunt est.Amet neque ex necessitatibus. Et qui sed eos rerum officiis. Quia quas impedit doloremque corporis quae provident cum.',
        'service_provider_id' => 193,
        'enquiries_count' => 1,
        'first_published_at' => '2017-03-02T00:00:00.000Z',
        'author' => { 'email' => 'email@example.com' },
        'countries' => [{ 'slug' => 'france' }],
        'types' => [{ 'slug' => 'private-sector' }],
        'sectors' => [{ 'slug' => 'agriculture-horticulture-fisheries' }],
        'values' => [{ 'slug' => '100k' }],
        'contacts' => [
          { 'email' => 'jorge@kreiger.net' }, { 'email' => 'art@johns.io' }
        ],
      },
  }.with_indifferent_access
  result.merge!(result_body)
  result
end
