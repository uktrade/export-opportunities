module Users
  class DownloadsController < BaseController
    after_action :verify_authorized, except: [:show]

    def show
      shortened_link_id = params[:id]
      # we use SSO id to identify user + hashed_id params
      user_id = logged_in_user_id
      @result = DocumentUrlShortener.new.s3_link(user_id, shortened_link_id)
      if @result
        file = DocumentStorage.new.read_file(@result.original_filename)
        if file == 'error, specified file does not exist'
          # user has access to file, but file has been deleted b/c of data retention policy
          @result = nil
        else
          send_data(file.body.read, filename: @result.original_filename, disposition: 'inline', stream: 'true', type: 'application/text', buffer_size: '4096')
        end

      end
    end

    def logged_in_user_id
      current_user.uid.to_i # TODO: mock or 3
    end
  end
end
