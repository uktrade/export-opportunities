require 'vcr'
require 'elasticsearch/extensions/test/cluster'
require 'capybara'
require 'webmock/rspec'
require 'yaml'
require 'phantomjs'

module Helpers
  def select2_select_multiple(select_these, _id)
    # This methods requires @javascript in the Scenario
    [select_these].flatten.each do |value|
      first('#s2id_#{_id}').click
      found = false
      within('#select2-drop') do
        all('li.select2-results__option').each do |result|
          next unless found
          if result.text == value
            result.click
            found = true
          end
        end
      end
    end
  end

  def get_content(*files)
    content = {}
    files.each do |file|
      content = content.merge YAML.load_file(File.join(Rails.root.to_s, 'app', 'content/') + file + '.yml')
    end
    content
  end

  # Updates elasticsearch indexes with the latest data from the database
  # Defaults to only refresh Opportunity, as is the most commonly used
  def refresh_elasticsearch(models=[Opportunity])
    models.each{ |m| m.import(refresh: true) }
  end

  # Returns number of shards for the test database
  def number_of_shards
    Elasticsearch::Model.client.cluster.
      health(index: 'opportunities_test')["active_shards"]
  end

  # Return JS value for checking in test code.
  def js_variable(name)
    id = name.gsub(/[^\w]/, '_')
    page.execute_script("(function() { \
      var text = document.createTextNode(" + name + "); \
      var element = document.createElement('span'); \
      element.setAttribute('id', '" + id + "'); \
      element.appendChild(text); \
      document.body.appendChild(element); \
    })()")
    text = page.find('#' + id).text
    page.execute_script("(function() { \
      var element = document.getElementById('" + id + "'); \
      if(element) { \
        document.body.removeChild(element); \
      } \
    })()")
    text
  end

  # This is complex but can be understood by reading jQuery documentation.
  # https://api.jquery.com/jQuery.ajaxTransport/
  #
  # Essentially, it is creating functionality that will check upon each AJAX
  # request if the requested URL matches the passed url.
  #
  # If URL matches, it will register the request as successful so the success
  # handler will kick in, but it will return the json value that was passed
  # to stub_ajax_request as though it was the retrieved data.
  #
  # The real request will be aborted because we have now faked a response.
  #
  # IMPORTANT: You will get a silent fail (in JS) if the gsub effort is removed.
  def stub_jquery_ajax(url, json)
    page.execute_script("$.ajaxTransport('json', function( options, originalOptions, jqXHR ) { \
        if(options.url == '" + url + "') { \
          return { \
            send: function( headers, completeCallback ) { \
              completeCallback(200, 'success', { text: '" + json.gsub(/"/, '\"') + "' } ); \
              jqXHR.abort(); \
            } \
          } \
        } \
        else { \
          console.log('THE URL DID NOT MATCH IN stub_ajax_request\\n'); \
          console.log('options.url: ' + options.url + '\\n'); \
          console.log('passed url: ' + '" + url + "' + '\\n'); \
        } \
      }); \
    ")
  end
end

# Capybara.register_driver :poltergeist do |app|
#   Capybara::Poltergeist::Driver.new(app, timeout: 2.minutes, phantomjs_options: ['--load-images=no'], phantomjs_logger: Rails.root.join('/log/test_phantomjs.log'), 'a')
# end

# For CircleCi
begin
  require 'capybara/poltergeist'
rescue => LoadError 
  raise "Poltergeist support requires the poltergeist gem to be available."
end

Phantomjs.path # Force install on require
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
end

RSpec.configure do |config|
  config.include Helpers
  config.around :each, elasticsearch: true do |example|
    [Opportunity, Subscription].each do |model|
      model.__elasticsearch__.create_index!(force: true)
      model.__elasticsearch__.refresh_index! if model.__elasticsearch__.index_exists? index: model.__elasticsearch__.index_name
    end
    example.run
    [Opportunity, Subscription].each do |model|
      # model.__elasticsearch__.client.indices.delete index: model.index_name
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
