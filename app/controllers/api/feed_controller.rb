module Api
  class FeedController < ApplicationController
    def index
      return bad_request! if !params.key?('shared_secret')
      return forbidden! if Figaro.env.ACTIVITY_STREAM_SHARED_SECRET.nil? || Figaro.env.ACTIVITY_STREAM_SHARED_SECRET.empty?
      return forbidden! if params[:shared_secret] != Figaro.env.ACTIVITY_STREAM_SHARED_SECRET

      enquiry = Enquiry.where.not(company_house_number: nil, company_house_number: '').first

      entry = if enquiry then
        '<entry>' \
        '</entry>'
      else
        ''
      end

      contents = \
        '<?xml version="1.0" encoding="UTF-8"?>' \
        '<feed xmlns="http://www.w3.org/2005/Atom">' \
          '<updated>' + DateTime.now.to_datetime.rfc3339 + '</updated>' \
          '<title>Export Opportunities Activity Stream</title>' \
          '<id>dit-export-opportunities-activity-stream-' + Rails.env + '</id>' + \
          entry + \
        '</feed>'
      respond_to do |format|
        response.headers['Content-Type'] = 'application/atom+xml'
        format.xml { render status: 200, xml: contents}
      end
    end

    def bad_request!
      render status: 400, xml: { status: 'Bad Request', code: 400 }.freeze
    end

    def forbidden!
      render status: 403, xml: { status: 'Forbidden', code: 403 }.freeze
    end
  end
end
