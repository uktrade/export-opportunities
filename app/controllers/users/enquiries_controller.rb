module Users
  class EnquiriesController < BaseController
    def show
      @enquiry = current_user.enquiries.find(params[:id])
      @enquiry_response = @enquiry.enquiry_responses.first
      @response_type = @enquiry_response ? @enquiry_response.response_type : 0
    end
  end
end
