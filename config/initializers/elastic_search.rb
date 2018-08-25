require 'faraday_middleware/aws_signers_v4'

# https://github.com/omniauth/omniauth/issues/872
Hashie.logger = Logger.new(nil)

Elasticsearch::Model.client = if Rails.env.production?
                                Elasticsearch::Client.new(url: ENV['ELASTICSEARCH_URL']) do |f|
                                  f.request :aws_signers_v4,
                                    credentials: Aws::Credentials.new(
                                      ENV['AWS_ACCESS_KEY_ID'],
                                      ENV['AWS_SECRET_ACCESS_KEY']
                                    ),
                                    service_name: 'es',
                                    region: ENV['AWS_REGION']

                                  f.adapter Faraday.default_adapter
                                end
                              else
                                Elasticsearch::Client.new host: '127.0.0.1:9200'
                              end
