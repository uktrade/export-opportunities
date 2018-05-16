require 'json'

def elastic_search_json(enquiry)
  wrapper = {
    :action_and_metadata => {
      :index => {
        :_index => 'company_timeline',
        :_type => '_doc',
        :_id => 'export-oportunity-enquiry-made-' + enquiry.id.to_s
      }
    },
    :source => {
      :date => enquiry.created_at.to_datetime.rfc3339,
      :activity => 'export-oportunity-enquiry-made',
      :company_house_number => enquiry.company_house_number
    }
  }
  return JSON.generate(wrapper)
end

MAX_PER_PAGE = 20

module Api
  class FeedController < ApplicationController
    def index
      return bad_request! if !params.key?('shared_secret')
      return forbidden! if Figaro.env.ACTIVITY_STREAM_SHARED_SECRET.nil? || Figaro.env.ACTIVITY_STREAM_SHARED_SECRET.empty?
      return forbidden! if params[:shared_secret] != Figaro.env.ACTIVITY_STREAM_SHARED_SECRET

      enquiries = Enquiry.where.not(company_house_number: nil, company_house_number: '').order('created_at DESC').take(MAX_PER_PAGE)

      entries = (enquiries.map do |enquiry|
        '<entry>' \
          '<id>dit-export-opportunities-activity-stream-enquiry-' + enquiry.id.to_s + '</id>' \
          '<title>Export opportunity enquiry made</title>' \
          '<updated>' + enquiry.updated_at.to_datetime.rfc3339 + '</updated>' \
          '<as:elastic_search_bulk>' + \
            elastic_search_json(enquiry) +
          '</as:elastic_search_bulk>' \
        '</entry>'
      end).join('')

      contents = \
        '<?xml version="1.0" encoding="UTF-8"?>' \
        '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:as="http://trade.gov.uk/activity-stream/v1">' \
          '<updated>' + DateTime.now.to_datetime.rfc3339 + '</updated>' \
          '<title>Export Opportunities Activity Stream</title>' \
          '<id>dit-export-opportunities-activity-stream-' + Rails.env + '</id>' + \
          entries + \
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
