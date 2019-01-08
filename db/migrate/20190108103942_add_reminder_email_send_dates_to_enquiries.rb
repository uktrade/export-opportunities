class AddReminderEmailSendDatesToEnquiries < ActiveRecord::Migration[5.2]
  def change
    add_column :enquiries, :response_reminder_sent_at, :datetime
    
    # Set all sent_at times to now so that there is not an
    # initial barrage of emails when the feature is released
    time = DateTime.now
    Enquiry.update_all(response_reminder_sent_at: time)
  end
end
