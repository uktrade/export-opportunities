require 'digest'

module Api
  class DocumentController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    def index
      params[:id].to_i
    end

    def create
      @result = {}
      doc_params = params['enquiry_response']
      unless doc_params
        Raven.capture_exception('no doc_params found. cant process document creation in enquiry response')
        raise Exception, 'no doc params found'
      end

      enquiry_id = doc_params['enquiry_id']
      user_id = doc_params['user_id']
      original_filename = doc_params['original_filename']
      validation_result = DocumentValidation.new.call(doc_params, doc_params['file_blob'])
      if validation_result[:errors]
        @result = validation_result
      else
        res = DocumentStorage.new.call(original_filename, doc_params['file_blob'].path)
        if res
          s3_filename = enquiry_id.to_s + '_' + user_id.to_s + '_' + original_filename
          document_url = 'https://s3.' + Figaro.env.aws_region_ptu! + '.amazonaws.com/' + Figaro.env.post_user_communication_s3_bucket! + '/' + s3_filename
          short_url = DocumentUrlShortener.new.shorten_and_save_link(document_url, user_id, enquiry_id, original_filename)
        else
          Raven.capture_exception('couldnt store file to S3:')
          Raven.capture_exception(doc_params)
          return {
            errors: {
              type: 'error saving',
              message: 'couldnt store file to S3',
            },
          }
        end
        @result = {
          status: 200,
          id: short_url,
          base_url: Figaro.env.domain! + '/export-opportunities/dashboard/downloads/',
        }
      end
      respond_to do |format|
        format.json { render json: { result: @result }, status: :ok }
        format.js { render json: { result: @result }, status: :ok }
        format.html { render json: { result: @result }, status: :ok }
      end
    end
  end
end
