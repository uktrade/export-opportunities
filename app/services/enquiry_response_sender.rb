class EnquiryResponseSender
  def call(enquiry_response, enquiry)
    EnquiryResponseMailer.send_enquiry_response(enquiry_response, enquiry).deliver_later!
  end
end
