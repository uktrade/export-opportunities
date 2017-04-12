OmniAuth.config.logger = Rails.logger

module OmniAuth
  module Strategies
    autoload :ExportingIsGreat, Rails.root.join('lib', 'omniauth', 'strategies', 'exporting_is_great')
  end
end
