class AddSignatureToEnquiryResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiry_responses, :signature, :text
  end
end
