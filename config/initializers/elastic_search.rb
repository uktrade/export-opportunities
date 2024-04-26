require 'json'

# https://github.com/omniauth/omniauth/issues/872
Hashie.logger = Logger.new(nil)

service_name = ENV.fetch('ES_SERVICE', 'opensearch')
Elasticsearch::Model.client = if Rails.env.production?
                                uri = JSON.parse(ENV['VCAP_SERVICES'])[service_name][0]["credentials"]["uri"]
                                Elasticsearch::Client.new(url: uri)
                              else
                                Elasticsearch::Client.new host: 'docker-elasticsearch:9200'
                              end
