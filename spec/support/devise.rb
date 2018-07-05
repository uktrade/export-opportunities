RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :feature
  config.include Warden::Test::Helpers, type: :request
  config.before :suite do
    Warden.test_mode!
  end
end
