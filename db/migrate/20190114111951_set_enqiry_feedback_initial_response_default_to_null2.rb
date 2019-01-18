class SetEnqiryFeedbackInitialResponseDefaultToNull2 < ActiveRecord::Migration[5.2]
  def change
    change_column_default :enquiry_feedbacks, :initial_response, from: 0, to: nil
    EnquiryFeedback.where(responded_at: nil, message: nil).update_all(initial_response: nil)
  end
end
