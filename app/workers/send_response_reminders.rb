class SendResponseReminders
  include Sidekiq::Worker

  #
  # Finds enquiries that do not have a completed response
  # and sends a reminder email 7 days later. Planned to run
  # every 8 days
  #
  def perform
    enquiries = Enquiry.where('enquiries.created_at > ?', 30.days.ago).
                        left_outer_joins(:enquiry_response).
                        joins(:opportunity).
                        where('opportunities.response_due_on > ?', DateTime.now).
                        where(opportunities: { status: :publish })

    enquiries.where(enquiry_responses: { enquiry_id: nil }).or(
      enquiries.where(enquiry_responses: { completed_at: nil })). 
        each do |enquiry|

      created = enquiry.created_at
      if(created < 7.days.ago && created >= 14.days.ago)
        reminder(enquiry)
      end
    end
  end

  def reminder(enquiry)
    if enquiry.response_reminder_sent_at.blank?
      ResponseReminderMailer.reminder(enquiry).deliver_later!
    end
  end
end


# Code for proposed emails 2, 3 and 4.
# Not yet used but likely in time, so leaving here [8 Jan 2019]
#
# elsif(created < 14.days.ago && created >= 21.days.ago)
#   second_reminder(enquiry)
# elsif(created < 21.days.ago && created >= 28.days.ago)
#   first_reminder_escalation(enquiry)
# elsif(created < 28.days.ago && created >= 35.days.ago)
#   second_reminder_escalation(enquiry)

# def second_reminder(enquiry)
#   if enquiry.response_second_reminder_sent_at.blank?
#     ResponseReminderMailer.second_reminder(enquiry).deliver_later!
#   end
# end

# def first_reminder_escalation(enquiry)
#   if enquiry.response_first_reminder_escalation_sent_at.blank?
#     ResponseReminderMailer.first_reminder_escalation(enquiry).deliver_later!
#   end
# end

# def second_reminder_escalation(enquiry)
#   if enquiry.response_second_reminder_escalation_sent_at.blank?
#     ResponseReminderMailer.second_reminder_escalation(enquiry).deliver_later!
#   end
# end