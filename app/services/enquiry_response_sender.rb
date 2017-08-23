class EnquiryResponseSender

  def call(enquiry_response, enquiry)
    enquiry_response = enquiry_response
    enquiry_response_type = enquiry_response.response_type
    @enquiry = enquiry
    editor_email = enquiry_response.editor.email
    @noreply_address = 'noreply@export.great.gov.uk'

    reply_to_address = if enquiry_response_type == 2 then
                         @editor_email.to_s
                       else
                         @noreply_address
                       end

    case enquiry_response_type
    when 1
      EnquiryResponseMailer.right_for_opportunity(enquiry_response, editor_email, reply_to_address).deliver_later!
    when 2
      EnquiryResponseMailer.more_information(enquiry_response, editor_email, reply_to_address).deliver_later!
    when 3
      EnquiryResponseMailer.not_right_for_opportunity(enquiry_response, editor_email, reply_to_address).deliver_later!
    when 4
      EnquiryResponseMailer.not_uk_registered(enquiry_response, editor_email, reply_to_address).deliver_later!
    when 5
      EnquiryResponseMailer.not_for_third_party(enquiry_response, editor_email, reply_to_address).deliver_later!
    end
    # EnquiryResponseMailer.send_enquiry_response(enquiry_response, enquiry).deliver_later!
  end
end
