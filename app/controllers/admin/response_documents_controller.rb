class Admin::ResponseDocumentsController < Admin::BaseController
  include ActionController::Live
  include VirusScannerHelper

  skip_before_action :authenticate_editor!

  def create
  end

  def response_documents_params
    params.require(:enquiry_response).permit(:email_attachment, :enquiry_response_id)
  end
end
