class AddSentAtToEnquiryResponse < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiry_responses, :completed_at, :datetime
  end
end
