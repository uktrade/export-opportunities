Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Set cache headers on static assets
  # See: http://hawkins.io/2012/07/advanced_caching_part_3-static_assets/
  config.static_cache_control = 'public, max-age=31536000'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Make links in emails work
  config.action_mailer.default_url_options = { host: Figaro.env.DOMAIN! }
  config.action_mailer.asset_host = Figaro.env.DOMAIN!

  # Where emails are sent from
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: Figaro.env.MAILER_HOST!,
    port: Figaro.env.MAILER_PORT!,
    authentication: :plain,
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'],
    domain: Figaro.env.MAILER_DOMAIN!,
    enable_starttls_auto: true,
  }

  # config.action_mailer.smtp_settings = {
  #   address: 'email-smtp.eu-west-1.amazonaws.com',
  #   authentication: :login,
  #   user_name: Figaro.env.AMAZON_SES_USERNAME!,
  #   password: Figaro.env.AMAZON_SES_PASSWORD!,
  #   enable_starttls_auto: true,
  #   port: '25',
  # }

  # Only log mailer actions of 'info' and above
  mailer_logger = Logger.new(STDOUT)
  mailer_logger.level = Logger::INFO
  config.action_mailer.logger = mailer_logger
end
