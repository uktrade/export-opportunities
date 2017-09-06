class AddSentAtToEnquiryResponse < ActiveRecord::Migration
  def change
    add_column :enquiry_responses, :completed_at, :datetime
    # remove_column :enquiry_responses, :email_attachment_file_name, :character
    # remove_column :enquiry_responses, :email_attachment_content_type, :character
    # remove_column :enquiry_responses, :email_attachment_file_size, :integer
    # remove_column :enquiry_responses, :email_attachment_updated_at, :timestamp
    # remove_column :enquiry_responses, :attachments, :json
  end
end
