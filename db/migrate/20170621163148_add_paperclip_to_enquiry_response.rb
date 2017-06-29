class AddPaperclipToEnquiryResponse < ActiveRecord::Migration
  def change
    add_attachment :enquiry_responses, :email_attachment
  end
end
