require "digest"

module Api
  class DocumentController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      params[:id].to_i
    end

    def create
      if request.body and params['params'] and params['params']['file_location']
        DocumentValidation.new.call(params['params'], params['params']['file_location'])

        @result = request.body
      else
        d1 = Digest::SHA256.digest(['make ids great again'].pack('H*'))
        d2 = Digest::SHA256.digest(d1)
        id = d2.reverse.unpack('H*').join

        @result = {
          status: 200,
          id: id,
          original_filename: 'double_sha256_header',
          base_url: 'http://localhost:3000/dashboard/downloads/' + id,
        }

        @error_result = {
            status: 500,
            error_message: 'INTERNAL SERVER ERROR',
        }
      end

      respond_to do |format|
        format.json { render status: 200, json: @result }
        format.js { render status: 200, json: @result }
      end
    end
  end
end
