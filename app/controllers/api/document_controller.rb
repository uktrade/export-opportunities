require "digest"

module Api
  class DocumentController < ApplicationController
    skip_before_action :verify_authenticity_token

    def index
      params[:id].to_i
    end

    def create
      d1 = Digest::SHA256.digest(['make ids great again'].pack('H*'))
      d2 = Digest::SHA256.digest(d1)
      id = d2.reverse.unpack('H*').join

      @result = {
        id: id,
        filename: 'double_sha256_header',
        base_url: 'http://localhost:3000/dashboard/downloads/' + id,
      }
      respond_to do |format|
        format.json { render status: 200, json: @result }
      end
    end
  end
end
