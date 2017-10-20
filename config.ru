# This file is used by Rack-based servers to start the application.

use Rack::CanonicalHost, ENV['domain'], cache_control: 'no-cache' if ENV['domain']

require ::File.expand_path('../config/environment', __FILE__)

run Rails.application
