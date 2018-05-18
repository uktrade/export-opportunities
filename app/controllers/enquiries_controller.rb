class EnquiriesController < ApplicationController
  before_action :require_sso!

  before_action :set_no_cache_headers, only: [:new]
  before_action :log_cloudfront_headers
  layout 'poc/layouts/enquiries'

  def new
    @opportunity = Opportunity.published.find_by!(slug: params[:slug])
    redirect_to opportunity_path(@opportunity) if @opportunity.expired?

    @enquiry = if enquiry_current_user
                 Enquiry.initialize_from_existing(enquiry_current_user.enquiries.last)
               else
                 Enquiry.new
               end
  end

  def create
    @opportunity = Opportunity.find_by!(slug: params[:slug])
    @enquiry = enquiry_current_user.enquiries.new(enquiry_params)
    @enquiry.opportunity = @opportunity

    if @enquiry.save && !@enquiry.opportunity.nil?
      EnquiryMailer.send_enquiry(@enquiry).deliver_later!
    else
      flash.now[:error] = @enquiry.errors.full_messages.join(', ')
      render :new
    end
  end

  private def enquiry_params
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

  private def set_no_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store'
  end

  private def log_cloudfront_headers
    Rails.logger.debug "RequestId: #{request.headers['X-Request-Id']}"
    Rails.logger.debug "Referrer: #{request.headers['Referer']}"

    request
      .headers
      .select { |h| h[0] =~ /Cloudfront/ }
      .each { |h| Rails.logger.debug h.join(': ') }
  end

  private def enquiry_current_user
    current_user
  end
end
