module Admin
  class UpdatesController < BaseController
    include ActionController::Live
    def index
      render 'index'
    end
  end
end
