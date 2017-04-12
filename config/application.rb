require File.expand_path('../boot', __FILE__)

require "rails"

require "sprockets/railtie"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module ExportOpportunities
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true

    config.autoload_paths += Dir[Rails.root.join("app", "services")]
    config.autoload_paths += Dir[Rails.root.join("app", "decorators")]
    config.autoload_paths += Dir[Rails.root.join("lib")]
    config.autoload_paths += Dir[Rails.root.join("lib", "modules")]
    config.autoload_paths += Dir[Rails.root.join("lib", "omniauth", "strategies")]
    config.action_view.sanitized_allowed_tags = %w(p em i strong b ul li ol)
    config.action_view.sanitized_allowed_attributes = []

    config.exceptions_app = routes

    # GZIP our responses when supported by client
    config.middleware.use Rack::Deflater

    # Use Sidekiq to process jobs from ActiveJob
    config.active_job.queue_adapter = :sidekiq

    # Stop Rails adding `field_with_errors` class to the labels
    # as this breaks the style. Input forms are all moved to the left
    # Preferably we would switch to using SimpleForm in the future.
    ActionView::Base.field_error_proc = proc do |html_tag, _instance|
      if html_tag =~ /^<label/
        html_tag.html_safe
      else
        "<div class=\"field_with_errors\">#{html_tag}</div>".html_safe
      end
    end
  end
end
