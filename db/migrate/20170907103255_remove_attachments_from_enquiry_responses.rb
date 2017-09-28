class RemoveAttachmentsFromEnquiryResponses < ActiveRecord::Migration
  def change
    if column_exists? :enquiry_responses, :attachments
      remove_column :enquiry_responses, :attachments, :json
    end
  end
end
