module Users
  class EnquiriesController < BaseController
    def show
      @enquiry = current_user.enquiries.find(params[:id])
    end
  end
end
