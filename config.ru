# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

use Rack::CanonicalHost, Figaro.env.domain! if Figaro.env.domain!

run Rails.application
