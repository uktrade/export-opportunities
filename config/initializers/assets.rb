# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.4'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Rails.application.config.sass.precision = 8
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
Rails.application.config.assets.precompile += %w[jquery-3.3.1.min.js]

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.prefix = '/export-opportunities/assets'


###################################
# 2018 New design beyond this point
###################################

# Transformation
# ---------------------------------
# CSS...
Rails.application.config.assets.precompile += %w[transformation/main.scss]
Rails.application.config.assets.precompile += %w[transformation/main_ie8_fixes.scss]
Rails.application.config.assets.precompile += %w[transformation/main_ie9_fixes.scss]
Rails.application.config.assets.precompile += %w[transformation/pages/landing.scss]
Rails.application.config.assets.precompile += %w[transformation/pages/results.scss]
Rails.application.config.assets.precompile += %w[transformation/pages/form.scss]
Rails.application.config.assets.precompile += %w[transformation/pages/opportunity.scss]
Rails.application.config.assets.precompile += %w[transformation/pages/enquiries.scss]
Rails.application.config.assets.precompile += %w[transformation/pages/notification.scss]

# Remove this when no longer need to support legacy template/design (not updated to transformation)
Rails.application.config.assets.precompile += %w[transformation_admin/temporary.css]

# JS...
Rails.application.config.assets.precompile += %w[transformation/dit.page.all.js]
Rails.application.config.assets.precompile += %w[transformation/dit.page.form.js]
Rails.application.config.assets.precompile += %w[transformation/dit.page.notification.js]
Rails.application.config.assets.precompile += %w[transformation/dit.page.landing.js]
Rails.application.config.assets.precompile += %w[transformation/dit.page.results.js]
Rails.application.config.assets.precompile += %w[transformation/dit.page.opportunity.js]
Rails.application.config.assets.precompile += %w[transformation/dit.page.enquiries.js]
Rails.application.config.assets.precompile += %w[transformation/dit.tagging.js]
Rails.application.config.assets.precompile += %w[transformation/third_party/*.js]

# Transformation Admin
# ---------------------------------
# CSS...
Rails.application.config.assets.precompile += %w[transformation_admin/main.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/opportunity.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/opportunity_index.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/opportunity_show.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/enquiries.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/enquiries_index.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/reports.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/stats.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/editors.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/help.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/pages/updates.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/main_ie8_fixes.scss]
Rails.application.config.assets.precompile += %w[transformation_admin/main_ie9_fixes.scss]

# JS...
Rails.application.config.assets.precompile += %w[transformation_admin/dit.page.all.js]
Rails.application.config.assets.precompile += %w[transformation_admin/dit.page.enquiries.js]
Rails.application.config.assets.precompile += %w[transformation_admin/dit.page.opportunity.js]
Rails.application.config.assets.precompile += %w[transformation_admin/dit.page.opportunity_index.js]
Rails.application.config.assets.precompile += %w[transformation_admin/dit.page.opportunity_show.js]
Rails.application.config.assets.precompile += %w[transformation_admin/dit.page.stats.js]
Rails.application.config.assets.precompile += %w[transformation_admin/dit.page.editors.js]


###################################
# 2019 External supporting files
###################################

# Export Components
# ---------------------------------
Rails.application.config.assets.precompile += %w[export-components.css]
Rails.application.config.assets.precompile += %w[search-icon.svg search.sgv]
Rails.application.config.assets.precompile += %w[great.svg]
Rails.application.config.assets.precompile += %w[dbt-logo.svg dfbt-logo-white.png]
Rails.application.config.assets.precompile += %w[eig-logo-stacked.svg]

Rails.application.config.assets.precompile += %w[dit.classes.Dropdown.js]
Rails.application.config.assets.precompile += %w[dit.components.greatheader.js]

# HCSAT
# ---------------------------------
Rails.application.config.assets.precompile += %w[green-tick.svg]
Rails.application.config.assets.precompile += %w[hcsat/conditional_other_reveal.js]
