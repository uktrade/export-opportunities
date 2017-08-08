module Api
  class DocumentController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      document_id = params[:id].to_i
    end

    def create
      pp params
      pp request.body

    end
  end
end


