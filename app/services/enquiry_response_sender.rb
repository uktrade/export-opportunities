class EnquiryResponseSender
  def call(enquiry_response, enquiry)
    enquiry_response_type = enquiry_response.response_type
    @enquiry = enquiry
    editor_email = enquiry_response.editor.email
    no_reply_address = Figaro.env.MAILER_NOREPLY_ADDRESS!

    case enquiry_response_type
    when 1
      EnquiryResponseMailer.right_for_opportunity(enquiry_response, editor_email).deliver_later!
    when 2
      # EnquiryResponseMailer.more_information(enquiry_response, editor_email).deliver_later!
      Rails.logger.warn('dont have more information emails')
    when 3
      EnquiryResponseMailer.not_right_for_opportunity(enquiry_response, editor_email, no_reply_address).deliver_later!
    when 4
      EnquiryResponseMailer.not_uk_registered(enquiry_response, editor_email, no_reply_address).deliver_later!
    when 5
      EnquiryResponseMailer.not_for_third_party(enquiry_response, editor_email, no_reply_address).deliver_later!
    end
  end
end
