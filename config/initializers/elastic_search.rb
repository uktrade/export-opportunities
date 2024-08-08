require 'json'

# https://github.com/omniauth/omniauth/issues/872
Hashie.logger = Logger.new(nil)

if Rails.env.production?
  if ENV['COPILOT_ENVIRONMENT_NAME'] # DBT Platform
    kwargs = { url: ENV.fetch('OPENSEARCH_URL') }
  elsif ENV['VCAP_SERVICES'] # Govt PaaS / Clout Foundry Platform
    kwargs = { url: JSON.parse(ENV['VCAP_SERVICES'])['opensearch'][0]["credentials"]["uri"] }
  else
    raise Exception, 'Platform type not identified'
  end
else
  kwargs = { host: '127.0.0.1:9200' }
end

Elasticsearch::Model.client = Elasticsearch::Client.new(kwargs)
