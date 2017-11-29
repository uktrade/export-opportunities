Rails.application.config.sass.precision = 8
Rails.application.config.assets.precompile += %w[application-admin.css]
Rails.application.config.assets.precompile += %w[application.css application-legacy.css email.css]
Rails.application.config.assets.precompile += %w[dit-ie8-2017.css]

Rails.application.config.assets.precompile += %w[modernizr.min.js]
Rails.application.config.assets.precompile += %w[oldie-support.min.js]
Rails.application.config.assets.precompile += %w[classlist.polyfill.min]
Rails.application.config.assets.precompile += %w[eventListener.polyfill.min]
Rails.application.config.assets.precompile += %w[selectivizr.min.js]
Rails.application.config.assets.precompile += %w[admin.js]
