# https://github.com/omniauth/omniauth/issues/872
Hashie.logger = Logger.new(nil)

Elasticsearch::Model.client = if Rails.env.production?
                                Elasticsearch::Client.new(url: JSON.parse(ENV['VCAP_SERVICES'])["elasticsearch"][0]["credentials"]["uri"])
                              else
                                Elasticsearch::Client.new host: '127.0.0.1:9200'
                              end