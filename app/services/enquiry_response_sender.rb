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
        layout '../admin/enquiry_responses/snippets/_more_information'
        layout '../admin/enquiry_responses/snippets/_more_information_addendum'
      when 3
        EnquiryResponseMailer.not_right_for_opportunity(enquiry_response, editor_email, reply_to_address).deliver_later!
      # layout '../admin/enquiry_responses/snippets/_not_right'
        # layout '../admin/enquiry_responses/snippets/_not_right_addendum'
      when 4
        layout '../admin/enquiry_responses/snippets/_not_uk_registered'
      when 5
        layout '../admin/enquiry_responses/snippets/_not_for_third_party'
    end
    # EnquiryResponseMailer.send_enquiry_response(enquiry_response, enquiry).deliver_later!
  end
end
