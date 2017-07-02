class EnquiryResponseSender
  def call(enquiry_response, enquiry, response_documents)
    EnquiryResponseMailer.send_enquiry_response(enquiry_response, enquiry, response_documents).deliver_later!
  end
end
