class AddSignatureToEnquiryResponses < ActiveRecord::Migration
  def change
    add_column :enquiry_responses, :signature, :text
  end
end
