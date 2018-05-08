require 'json'

module Api
  class ActivityStreamController < ApplicationController
    def index
      contents = {}
      respond_to do |format|
        format.json { render status: 200, json: contents.to_json}
      end
    end
  end
end
