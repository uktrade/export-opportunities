module Api
  class DocumentController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      params[:id].to_i
    end

    def create
      params[:id].to_i
    end
  end
end
