RSpec.configure do |config|
  config.before :each do
    Elasticsearch::Model.client = Elasticsearch::Client.new host: Figaro.env.elastic_search_url!
  end
end
