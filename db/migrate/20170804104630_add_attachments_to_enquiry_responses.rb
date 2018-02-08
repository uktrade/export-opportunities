class AddAttachmentsToEnquiryResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiry_responses, :attachments, :json
  end
end
