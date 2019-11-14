require 'vcr'
require 'elasticsearch/extensions/test/cluster'
require 'capybara'
require 'webmock/rspec'
require 'yaml'

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

  config.around :each, sso: true do |example|
    directory_sso_api_url = Figaro.env.DIRECTORY_SSO_API_DOMAIN + '/api/v1/session-user/?session_key='
    stub_request(:get, directory_sso_api_url).to_return(body: {
      id: 1,
      email: "john@example.com",
      hashed_uuid: "88f9f63c93cd30c9a471d80548ef1d4552c5546c9328c85a171f03a8c439b23e",
      user_profile: { 
        first_name: "John",  
        last_name: "Bull",  
        job_title: "Owner",  
        mobile_phone_number: "123123123"
      }
    }
    .to_json, status: 200)
    example.run
  end

  config.profile_examples = nil
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.order = :random
  # config.seed = 41448
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

def opportunity_params(title: 'title',
                       service_provider_id: 5,
                       sector_ids: ['2'],
                       teaser: 'teaser',
                       description: 'description',
                       opportunity_cpvs: [{ 
                                            industry_id: 38511000,
                                            industry_scheme: 'test_scheme'
                                           }])
  {
    title: title,
    country_ids: ['1'],
    sector_ids: sector_ids,
    type_ids: ['3'],
    value_ids: ['4'],
    teaser: teaser,
    response_due_on: '2015-02-01',
    description: description,
    contacts_attributes: [
      { name: 'foo', email: 'email@foo.com' },
      { name: 'bar', email: 'email@bar.com' },
    ],
    service_provider_id: service_provider_id,
    opportunity_cpvs: opportunity_cpvs
  }
end

# EXAMPLE CPV search URL and RESPONSE
# -----------------------------------------------------------------------
# URL =
# https://dit-matcher-staging.london.cloudapps.digital/api/cn/cpv?format=json&description=meat
#
# RESPONSE =
def cpv_search_response
  JSON.generate(
    [
      {
        'order': '1971397',
        'level': '5',
        'code': '150110100080',
        'parent': '150110000080',
        'code2': '1501 10 10',
        'parent2': '1501 10',
        'description': '-- For industrial uses other than manufacture',
        'english_text': 'Lard',
        'parent_description': 'Lard',
      }, {
        'order': '1971400',
        'level': '5',
        'code': '150120100080',
        'parent': '150120000080',
        'code2': '1501 20 10',
        'parent2': '1501 20',
        'description': '-- For industrial uses other than manufacture',
        'english_text': 'Pig fat',
        'parent_description': 'Pig fat',
      }, {
        'order': '1971405',
        'level': '5',
        'code': '150210100080',
        'parent': '150210000080',
        'code2': '1502 10 10',
        'parent2': '1502 10',
        'description': '-- For industrial uses other than manufacture',
        'english_text': 'Tallow of bovine animals',
        'parent_description': 'Tallow of bovine animals',
      }, {
        'order': '1971408',
        'level': '5',
        'code': '150290100080',
        'parent': '150290000080',
        'code2': '1502 90 10',
        'parent2': '1502 90',
        'description': '-- For industrial uses other than manufacture',
        'english_text': 'Fats of bovine animals',
        'parent_description': 'Fats of bovine animals',
      }, {
        'order': '1971414',
        'level': '4',
        'code': '150300300080',
        'parent': '150300000080',
        'code2': '1503 00 30',
        'parent2': '1503 00',
        'description': '- Tallow oil for industrial uses other than the manufacture of foodstuffs for human consumption',
        'english_text': 'Tallow oil for industrial uses (excl. for production of foodstuffs and emulsified',
        'parent_description': 'lard oil',
      }, {
        'order': '1971434',
        'level': '5',
        'code': '150710100080',
        'parent': '150710000080',
        'code2': '1507 10 10',
        'parent2': '1507 10',
         'description': '-- For technical or industrial uses other than the manufacture of foodstuffs for human consumption',
        'english_text': 'Crude soya-bean oil',
        'parent_description': 'whether or not degummed',
      }, {
        'order': '1971437',
        'level': '5',
        'code': '150790100080',
        'parent': '150790000080',
        'code2': '1507 90 10',
        'parent2': '1507 90',
        'description': '-- For technical or industrial uses other than the manufacture of foodstuffs for human consumption',
        'english_text': 'Soya-bean oil and its fractions',
        'parent_description': 'Soya-bean oil and its fractions',
      }, {
        'order': '1971441',
        'level': '5',
        'code': '150810100080',
        'parent': '150810000080',
        'code2': '1508 10 10',
        'parent2': '1508 10',
        'description': '-- For technical or industrial uses other than the manufacture of foodstuffs for human consumption',
        'english_text': 'Crude groundnut oil for technical or industrial uses (excl. for production of foodstuffs)',
        'parent_description': 'Crude groundnut oil',
      }, {
        'order': '1971444',
        'level': '5',
        'code': '150890100080',
        'parent': '150890000080',
        'code2': '1508 90 10',
        'parent2': '1508 90',
        'description': '-- For technical or industrial uses other than the manufacture of foodstuffs for human consumption',
        'english_text': 'Groundnut oil and its fractions',
        'parent_description': 'Groundnut oil and its fractions',
      }
    ]
  )
end

