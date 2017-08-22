module Users
  class DownloadsController < BaseController
    after_action :verify_authorized, except: [:show]

    def show
      shorten_link_id = params[:id]
      # we use SSO id to identify user + hashed_id params
      user_id = logged_in_user_id
      @result = DocumentUrlShortener.new.s3_link(user_id, 1, shorten_link_id)
      if @result
        file = DocumentStorage.new.read_file(@result.original_filename)
        send_data(file.body.read, filename: @result.original_filename, disposition: 'inline', stream: 'true', type: 'application/text', buffer_size: '4096')
      end
    end

    def logged_in_user_id
      current_user.uid # TODO: mock or 3
    end
  end
end
