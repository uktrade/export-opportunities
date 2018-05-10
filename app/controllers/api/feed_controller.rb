module Api
  class FeedController < ApplicationController
    def index
      return forbidden! if Figaro.env.api_feed_shared_secret.nil? || Figaro.env.api_feed_shared_secret.empty?

      contents = \
        '<?xml version="1.0" encoding="UTF-8"?>' \
        '<feed xmlns="http://www.w3.org/2005/Atom">' \
          '<updated>' + DateTime.now.to_datetime.rfc3339 + '</updated>' \
          '<title>Export Opportunities Activity Stream</title>' \
          '<id>dit-export-opportunities-activity-stream-' + Rails.env + '</id>' \
        '</feed>'
      respond_to do |format|
        response.headers['Content-Type'] = 'application/atom+xml'
        format.xml { render status: 200, xml: contents}
      end
    end

    def forbidden!
      render status: 403, xml: { status: 'Forbidden', code: 403 }.freeze
    end
  end
end
