module Admin
  class UpdatesController < BaseController
    include ActionController::Live
    def index
      @admin_updates = true
      render layout: 'admin_transformed'
    end
  end
end
