class UpdateEnquiryResponse
  def initialize(enquiry_response)
    @enquiry_response = enquiry_response
  end

  def call(params)
    @enquiry_response.assign_attributes(params)
    @enquiry_response.save

    @enquiry_response
  end

  def enquiry_response_sent
    byebug
    @enquiry_response.sent_at = DateTime.now
    @enquiry_response.update!
  end
end