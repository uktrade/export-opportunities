class AddEnquiryResponseTypeToEnquiryResponses < ActiveRecord::Migration
  def change
    add_column :enquiry_responses, :response_type, :integer
  end
end

