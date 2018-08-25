RSpec.configure do |config|
  config.before :each do
    Elasticsearch::Model.client = Elasticsearch::Client.new host: ENV.fetch('ELASTICSEARCH_URL')
  end
end
