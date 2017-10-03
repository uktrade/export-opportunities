module Users
  class EnquiriesController < BaseController
    def show
      @enquiry = Enquiry.find(params[:id])
      # @enquiry = current_user.enquiries.find(params[:id])
      @enquiry_response = @enquiry.enquiry_response
      @response_type = @enquiry_response ? @enquiry_response.response_type : 0
    end
  end
end
