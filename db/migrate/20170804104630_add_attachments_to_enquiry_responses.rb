class AddAttachmentsToEnquiryResponses < ActiveRecord::Migration
  def change
    add_column :enquiry_responses, :attachments, :json
  end
end
