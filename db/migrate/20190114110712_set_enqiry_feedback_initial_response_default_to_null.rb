class SetEnqiryFeedbackInitialResponseDefaultToNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :enquiry_feedbacks, :initial_response, from: false, to: true
  end
end
