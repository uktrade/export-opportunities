class AddMessageToEnquiryFeedback < ActiveRecord::Migration[4.2]
  def change
    add_column :enquiry_feedbacks, :message, :string
  end
end
