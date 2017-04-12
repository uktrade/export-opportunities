require 'faraday_middleware/aws_signers_v4'

if Rails.env.production? # || Rails.env.development?
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: Figaro.env.elastic_search_url) do |f|
    f.request :aws_signers_v4,
      credentials: Aws::Credentials.new(
        Figaro.env.aws_access_key_id,
        Figaro.env.aws_secret_access_key
      ),
      service_name: 'es',
      region: Figaro.env.aws_region

    f.adapter Faraday.default_adapter
  end
end
