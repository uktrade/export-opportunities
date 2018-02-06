# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.1'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Rails.application.config.sass.precision = 8
Rails.application.config.assets.precompile += %w[header-footer.css]
Rails.application.config.assets.precompile += %w[application-admin.css]
Rails.application.config.assets.precompile += %w[application.css application-legacy.css email.css]
Rails.application.config.assets.precompile += %w[dit-ie8-2017.css]

Rails.application.config.assets.precompile += %w[modernizr.min.js]
Rails.application.config.assets.precompile += %w[oldie-support.min.js]
Rails.application.config.assets.precompile += %w[classlist.polyfill.min]
Rails.application.config.assets.precompile += %w[eventListener.polyfill.min]
Rails.application.config.assets.precompile += %w[selectivizr.min.js]
Rails.application.config.assets.precompile += %w[admin.js]
Rails.application.config.assets.precompile += %w[header-footer.js]
Rails.application.config.assets.precompile += %w[jquery3.2.0.js]

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# New design update stuff after this point.
Rails.application.config.assets.precompile += %w( updated/admin.css )
Rails.application.config.assets.precompile += %w( updated/layouts/help.css )

# International (POC) files beyond this point
Rails.application.config.assets.precompile += %w( international.css )
Rails.application.config.assets.precompile += %w( international.js )
