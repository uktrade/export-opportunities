require 'digest'

module Api
  class DocumentController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      params[:id].to_i
    end

    def create
      params = params['params'] if params
      if params
        DocumentValidation.new.call(params, params['file_blob'])
        res = DocumentStorage.new.call(params['filename'], params['file_blob'])
        if res
          document_url = 'https://s3.' + Figaro.env.aws_region! + '.amazonaws.com/' + Figaro.env.post_user_communication_s3_bucket! + '/' + params['filename']
          short_url = DocumentUrlShortener.new.call(document_url, params['user_id'], params['enquiry_id'])
        else
          raise Exception, 'cant save file to S3'
        end
        @result = {
          status: 200,
          id: short_url,
          base_url: Figaro.env.domain! + '/dashboard/downloads/',
        }
      else
        d1 = Digest::SHA256.digest(['make ids great again'].pack('H*'))
        d2 = Digest::SHA256.digest(d1)
        id = d2.reverse.unpack('H*').join

        @result = {
          status: 200,
          id: id,
          original_filename: 'double_sha256_header',
          base_url: 'http://localhost:3000/dashboard/downloads/',
        }

        @error_result = {
          status: 500,
          error_message: 'INTERNAL SERVER ERROR',
        }
      end

      respond_to do |format|
        format.json { render status: 200, json: @result }
        format.js { render status: 200, js: @result }
        format.html { render status: 200, html: @result }
      end
    end
  end
end
