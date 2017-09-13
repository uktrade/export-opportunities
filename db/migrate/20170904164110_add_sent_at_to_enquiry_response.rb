class AddSentAtToEnquiryResponse < ActiveRecord::Migration
  def change
    add_column :enquiry_responses, :completed_at, :datetime
  end
end
