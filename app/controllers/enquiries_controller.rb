class EnquiriesController < ApplicationController
  include ApplicationHelper
  before_action :require_sso!

  before_action :set_no_cache_headers, only: [:new]
  before_action :log_cloudfront_headers

  def new
    @opportunity = Opportunity.published.find_by!(slug: params[:slug])
    @enquiry = Enquiry.new_from_sso(cookies[Figaro.env.SSO_SESSION_COOKIE])

    @trade_profile_url = trade_profile(@enquiry.company_house_number)
    if @opportunity.expired?
      redirect_to opportunity_path(@opportunity)
    else
      render layout: 'enquiries'
    end
  end

  def create
    @opportunity = Opportunity.find_by!(slug: params[:slug])
    @enquiry = current_user.enquiries.new(enquiry_params)
    @trade_profile_url = trade_profile(@enquiry.company_house_number)
    @enquiry.opportunity = @opportunity

    if @enquiry.save && !@enquiry.opportunity.nil?
      EnquiryMailer.send_enquiry(@enquiry).deliver_later!
      render layout: 'notification'
    else
      flash.now[:error] = @enquiry.errors.full_messages.join(', ')
      render :new
    end
  end

  private

    def enquiry_params
      params.require(:enquiry).permit(%i[
                                        first_name
                                        last_name
                                        company_telephone
                                        company_name
                                        company_address
                                        company_house_number
                                        company_postcode
                                        company_url
                                        existing_exporter
                                        company_sector
                                        company_explanation
                                        data_protection
                                      ])
    end

    def log_cloudfront_headers
      Rails.logger.debug "RequestId: #{request.headers['X-Request-Id']}"
      Rails.logger.debug "Referrer: #{request.headers['Referer']}"

      request
        .headers
        .select { |h| h[0] =~ /Cloudfront/ }
        .each { |h| Rails.logger.debug h.join(': ') }
    end

    def private_company_data; end
end
