class AddPaperclipResponseDocument < ActiveRecord::Migration
  def change
    remove_attachment :enquiry_responses, :email_attachment
    add_attachment :response_documents, :email_attachment
  end
end
