OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = [:post, :get]

module OmniAuth
  module Strategies
    autoload :ExportingIsGreat, Rails.root.join('lib', 'omniauth', 'strategies', 'exporting_is_great')
  end
end
