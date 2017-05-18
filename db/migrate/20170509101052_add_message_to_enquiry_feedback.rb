class AddMessageToEnquiryFeedback < ActiveRecord::Migration
  def change
    add_column :enquiry_feedbacks, :message, :string
  end
end
