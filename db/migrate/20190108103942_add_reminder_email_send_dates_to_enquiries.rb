class AddReminderEmailSendDatesToEnquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :enquiries, :response_first_reminder_sent_at, :datetime
    add_column :enquiries, :response_second_reminder_sent_at, :datetime
    add_column :enquiries, :response_first_reminder_escalation_sent_at, :datetime
    add_column :enquiries, :response_second_reminder_escalation_sent_at, :datetime
    
    # Set all sent_at times to now so that there is not an
    # initial barrage of emails when the feature is released
    time = DateTime.now
    Enquiry.update_all(
        response_first_reminder_sent_at: time,
        response_second_reminder_sent_at: time,
        response_first_reminder_escalation_sent_at: time,
        response_second_reminder_escalation_sent_at: time
      )
  end
end
