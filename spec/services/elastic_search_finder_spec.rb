require 'spec_helper'
require 'app/services/elastic_search_finder'
require 'active_support/core_ext/hash'

RSpec.describe ElasticSearchFinder, type: :service do
  subject { described_class.new }

  describe '#call' do
    it 'should return all documents' do
      skip("deprecated since we don't use stubs anymore here")
      stub_api_call('match_all' => [example_elasticsearch_response], 'sort' => OpenStruct.new(column: :response_due_on, order: :desc))
      expect(subject).to receive(:call).with('match_all', 'sort')
      result = subject.call('match_all', 'sort')
      expect(result).to be_kind_of(Array)
      expect(result.first).to be_kind_of(Opportunity)
    end
  end

  def stub_api_call(result_body = {})
    stub_request(:get, %r{'//profile_dashboard?.+//'}).to_return(status: 200, body: JSON.generate(result_body))
  end

  def example_elasticsearch_response
    {
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
  end
end
