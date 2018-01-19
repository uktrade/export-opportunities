class AddDocumentsToEnquiryResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiry_responses, :documents, :string
  end
end