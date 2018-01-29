module Admin
  class UpdatesController < BaseController
    include ActionController::Live
    def index
      @admin_updates = true
      render 'index'
    end
  end
end
