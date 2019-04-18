# https://github.com/omniauth/omniauth/issues/872
Hashie.logger = Logger.new(nil)

Elasticsearch::Model.client = if Rails.env.production?
                                Elasticsearch::Client.new(url: Figaro.env.elastic_search_url) do |f|
                                  # f.request :aws_signers_v4,
                                  #           credentials: Aws::Credentials.new(
                                  #               Figaro.env.aws_access_key_id,
                                  #               Figaro.env.aws_secret_access_key
                                  #           ),
                                  #           service_name: 'es',
                                  #           region: Figaro.env.aws_region

                                  f.adapter Faraday.default_adapter
                                end
                                else
                                  Elasticsearch::Client.new host: '127.0.0.1:9200'
                                end
