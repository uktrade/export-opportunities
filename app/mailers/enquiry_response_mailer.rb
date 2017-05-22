class EnquiryResponseMailer < ApplicationMailer
  layout 'eig-email'

  def send_enquiry_response(enquiry_response, enquiry)
    @enquiry_response = enquiry_response
    @enquiry = enquiry
    # @subscription = SubscriptionPresenter.new(subscription)

    mail from: "Export opportunities #{@enquiry_response.editor.email}" ,to: @enquiry.user.email ,subject: "Update on your enquiry for the export opportunity #{@enquiry.opportunity.title}"
  end
end
