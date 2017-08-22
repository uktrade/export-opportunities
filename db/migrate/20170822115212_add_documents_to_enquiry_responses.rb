class AddDocumentsToEnquiryResponses < ActiveRecord::Migration
  def change
    add_column :enquiry_responses, :documents, :string
  end
end