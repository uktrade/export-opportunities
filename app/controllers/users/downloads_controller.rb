module Users
  class DownloadsController < BaseController
    after_action :verify_authorized, except: [:show]

    def show
      shorten_link_id = params[:id]
      # we use SSO id to identify user + hashed_id params
      user_id = logged_in_user_id
      @result = DocumentUrlShortener.new.s3_link(user_id, 1, shorten_link_id)

      file = DocumentStorage.new.read_file(@result.original_filename)
      send_data(file.body.read,
                filename: @result.original_filename,
                disposition: 'inline',
                stream: 'true',
                type: 'application/text',
                buffer_size: '4096'
      )
    end

    def logged_in_user_id
      3 #TODO: current_user.uid
    end
  end
end
