require 'json'

module Api
  class ActivityStreamController < ApplicationController
    def index
      # 401 if the server can't authenticate the request

      # Ensure Authorization header is sent
      unless request.headers.key?('Authorization')
        respond_to do |format|
          response.headers['Content-Type'] = 'application/json'
          error_object = {
            message: 'Authorization header is missing',
          }
          format.json { render status: 401, json: error_object.to_json }
        end
        return
      end

      contents = {}
      respond_to do |format|
        response.headers['Content-Type'] = 'application/activity+json'
        format.json { render status: 200, json: contents.to_json }
      end
    end
  end
end
