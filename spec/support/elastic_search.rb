RSpec.configure do |config|
  config.before :each do
    Elasticsearch::Model.client = Elasticsearch::Client.new host: 'localhost:9250'
    stub_request(:any, /localhost:9250/)
  end
end
