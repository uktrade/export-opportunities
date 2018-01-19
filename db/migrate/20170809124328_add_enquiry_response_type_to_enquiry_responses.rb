class AddEnquiryResponseTypeToEnquiryResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiry_responses, :response_type, :integer
  end
end

