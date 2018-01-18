# -*- encoding: utf-8 -*-
# stub: devise_security_extension 0.10.0 ruby lib

Gem::Specification.new do |s|
  s.name = "devise_security_extension".freeze
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marco Scholl".freeze, "Alexander Dreher".freeze]
<<<<<<< HEAD
  s.date = "2018-01-19"
=======
  s.date = "2018-01-18"
>>>>>>> 30f043d9... (feature) updated rails to 5.1, ruby to 2.4.3
  s.description = "An enterprise security extension for devise, trying to meet industrial standard security demands for web applications.".freeze
  s.email = "team@phatworx.de".freeze
  s.files = [".document".freeze, ".gitignore".freeze, ".rubocop.yml".freeze, ".travis.yml".freeze, "Gemfile".freeze, "Gemfile.lock".freeze, "LICENSE.txt".freeze, "README.md".freeze, "Rakefile".freeze, "app/controllers/devise/paranoid_verification_code_controller.rb".freeze, "app/controllers/devise/password_expired_controller.rb".freeze, "app/views/devise/paranoid_verification_code/show.html.erb".freeze, "app/views/devise/password_expired/show.html.erb".freeze, "config/locales/de.yml".freeze, "config/locales/en.yml".freeze, "config/locales/es.yml".freeze, "config/locales/it.yml".freeze, "devise_security_extension.gemspec".freeze, "lib/devise_security_extension.rb".freeze, "lib/devise_security_extension/controllers/helpers.rb".freeze, "lib/devise_security_extension/hooks/expirable.rb".freeze, "lib/devise_security_extension/hooks/paranoid_verification.rb".freeze, "lib/devise_security_extension/hooks/password_expirable.rb".freeze, "lib/devise_security_extension/hooks/session_limitable.rb".freeze, "lib/devise_security_extension/models/database_authenticatable_patch.rb".freeze, "lib/devise_security_extension/models/expirable.rb".freeze, "lib/devise_security_extension/models/old_password.rb".freeze, "lib/devise_security_extension/models/paranoid_verification.rb".freeze, "lib/devise_security_extension/models/password_archivable.rb".freeze, "lib/devise_security_extension/models/password_expirable.rb".freeze, "lib/devise_security_extension/models/secure_validatable.rb".freeze, "lib/devise_security_extension/models/security_questionable.rb".freeze, "lib/devise_security_extension/models/session_limitable.rb".freeze, "lib/devise_security_extension/orm/active_record.rb".freeze, "lib/devise_security_extension/patches.rb".freeze, "lib/devise_security_extension/patches/confirmations_controller_captcha.rb".freeze, "lib/devise_security_extension/patches/confirmations_controller_security_question.rb".freeze, "lib/devise_security_extension/patches/controller_captcha.rb".freeze, "lib/devise_security_extension/patches/controller_security_question.rb".freeze, "lib/devise_security_extension/patches/passwords_controller_captcha.rb".freeze, "lib/devise_security_extension/patches/passwords_controller_security_question.rb".freeze, "lib/devise_security_extension/patches/registrations_controller_captcha.rb".freeze, "lib/devise_security_extension/patches/sessions_controller_captcha.rb".freeze, "lib/devise_security_extension/patches/unlocks_controller_captcha.rb".freeze, "lib/devise_security_extension/patches/unlocks_controller_security_question.rb".freeze, "lib/devise_security_extension/rails.rb".freeze, "lib/devise_security_extension/routes.rb".freeze, "lib/devise_security_extension/schema.rb".freeze, "lib/devise_security_extension/version.rb".freeze, "lib/generators/devise_security_extension/install_generator.rb".freeze, "lib/generators/templates/devise_security_extension.rb".freeze, "test/dummy/Rakefile".freeze, "test/dummy/app/controllers/application_controller.rb".freeze, "test/dummy/app/controllers/captcha/sessions_controller.rb".freeze, "test/dummy/app/controllers/foos_controller.rb".freeze, "test/dummy/app/controllers/security_question/unlocks_controller.rb".freeze, "test/dummy/app/models/.gitkeep".freeze, "test/dummy/app/models/captcha_user.rb".freeze, "test/dummy/app/models/secure_user.rb".freeze, "test/dummy/app/models/security_question_user.rb".freeze, "test/dummy/app/models/user.rb".freeze, "test/dummy/app/views/foos/index.html.erb".freeze, "test/dummy/config.ru".freeze, "test/dummy/config/application.rb".freeze, "test/dummy/config/boot.rb".freeze, "test/dummy/config/database.yml".freeze, "test/dummy/config/environment.rb".freeze, "test/dummy/config/environments/test.rb".freeze, "test/dummy/config/initializers/devise.rb".freeze, "test/dummy/config/initializers/migration_class.rb".freeze, "test/dummy/config/routes.rb".freeze, "test/dummy/config/secrets.yml".freeze, "test/dummy/db/migrate/20120508165529_create_tables.rb".freeze, "test/dummy/db/migrate/20150402165590_add_verification_columns.rb".freeze, "test/dummy/db/migrate/20150407162345_add_verification_attempt_column.rb".freeze, "test/dummy/db/migrate/20160320162345_add_security_questions_fields.rb".freeze, "test/test_captcha_controller.rb".freeze, "test/test_helper.rb".freeze, "test/test_install_generator.rb".freeze, "test/test_paranoid_verification.rb".freeze, "test/test_password_archivable.rb".freeze, "test/test_password_expirable.rb".freeze, "test/test_password_expired_controller.rb".freeze, "test/test_secure_validatable.rb".freeze, "test/test_security_question_controller.rb".freeze]
  s.homepage = "https://github.com/phatworx/devise_security_extension".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1.0".freeze)
  s.rubyforge_project = "devise_security_extension".freeze
  s.rubygems_version = "2.6.14".freeze
  s.summary = "Security extension for devise".freeze
  s.test_files = ["test/dummy/Rakefile".freeze, "test/dummy/app/controllers/application_controller.rb".freeze, "test/dummy/app/controllers/captcha/sessions_controller.rb".freeze, "test/dummy/app/controllers/foos_controller.rb".freeze, "test/dummy/app/controllers/security_question/unlocks_controller.rb".freeze, "test/dummy/app/models/.gitkeep".freeze, "test/dummy/app/models/captcha_user.rb".freeze, "test/dummy/app/models/secure_user.rb".freeze, "test/dummy/app/models/security_question_user.rb".freeze, "test/dummy/app/models/user.rb".freeze, "test/dummy/app/views/foos/index.html.erb".freeze, "test/dummy/config.ru".freeze, "test/dummy/config/application.rb".freeze, "test/dummy/config/boot.rb".freeze, "test/dummy/config/database.yml".freeze, "test/dummy/config/environment.rb".freeze, "test/dummy/config/environments/test.rb".freeze, "test/dummy/config/initializers/devise.rb".freeze, "test/dummy/config/initializers/migration_class.rb".freeze, "test/dummy/config/routes.rb".freeze, "test/dummy/config/secrets.yml".freeze, "test/dummy/db/migrate/20120508165529_create_tables.rb".freeze, "test/dummy/db/migrate/20150402165590_add_verification_columns.rb".freeze, "test/dummy/db/migrate/20150407162345_add_verification_attempt_column.rb".freeze, "test/dummy/db/migrate/20160320162345_add_security_questions_fields.rb".freeze, "test/test_captcha_controller.rb".freeze, "test/test_helper.rb".freeze, "test/test_install_generator.rb".freeze, "test/test_paranoid_verification.rb".freeze, "test/test_password_archivable.rb".freeze, "test/test_password_expirable.rb".freeze, "test/test_password_expired_controller.rb".freeze, "test/test_secure_validatable.rb".freeze, "test/test_security_question_controller.rb".freeze]

  s.installed_by_version = "2.6.14" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>.freeze, ["< 6.0", ">= 3.2.6"])
      s.add_runtime_dependency(%q<devise>.freeze, ["< 5.0", ">= 3.0.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["< 2.0", ">= 1.3.0"])
      s.add_development_dependency(%q<sqlite3>.freeze, ["~> 1.3.10"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0"])
      s.add_development_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_development_dependency(%q<easy_captcha>.freeze, ["~> 0"])
      s.add_development_dependency(%q<rails_email_validator>.freeze, ["~> 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
    else
      s.add_dependency(%q<railties>.freeze, ["< 6.0", ">= 3.2.6"])
      s.add_dependency(%q<devise>.freeze, ["< 5.0", ">= 3.0.0"])
      s.add_dependency(%q<bundler>.freeze, ["< 2.0", ">= 1.3.0"])
      s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.10"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0"])
      s.add_dependency(%q<minitest>.freeze, [">= 0"])
      s.add_dependency(%q<easy_captcha>.freeze, ["~> 0"])
      s.add_dependency(%q<rails_email_validator>.freeze, ["~> 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<railties>.freeze, ["< 6.0", ">= 3.2.6"])
    s.add_dependency(%q<devise>.freeze, ["< 5.0", ">= 3.0.0"])
    s.add_dependency(%q<bundler>.freeze, ["< 2.0", ">= 1.3.0"])
    s.add_dependency(%q<sqlite3>.freeze, ["~> 1.3.10"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0"])
    s.add_dependency(%q<minitest>.freeze, [">= 0"])
    s.add_dependency(%q<easy_captcha>.freeze, ["~> 0"])
    s.add_dependency(%q<rails_email_validator>.freeze, ["~> 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
  end
end
