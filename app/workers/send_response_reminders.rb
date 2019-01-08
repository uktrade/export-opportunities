class SendResponseReminders
  include Sidekiq::Worker

  def perform
    Enquiry.where('enquiries.created_at > ?', 30.days.ago).
            left_outer_joins(:enquiry_response).
            where(enquiry_responses: { enquiry_id: nil }).
            joins(:opportunity).
            where('opportunities.response_due_on > ?', DateTime.now).
            where(opportunities: { status: :publish }).each do |enquiry|

      created = enquiry.created_at
      if(created < 7.days.ago && created >= 14.days.ago)
        first_reminder(enquiry)
      elsif(created < 14.days.ago && created >= 21.days.ago)
        second_reminder(enquiry)
      elsif(created < 21.days.ago && created >= 28.days.ago)
        first_reminder_escalation(enquiry)
      elsif(created < 28.days.ago && created >= 35.days.ago)
        second_reminder_escalation(enquiry)
      end
    end
  end

  def first_reminder(enquiry)
    if enquiry.response_first_reminder_sent_at.blank?
      ResponseReminderMailer.first_reminder(enquiry).deliver_later!
    end
  end

  def second_reminder(enquiry)
    if enquiry.response_second_reminder_sent_at.blank?
      ResponseReminderMailer.second_reminder(enquiry).deliver_later!
    end
  end

  def first_reminder_escalation(enquiry)
    if enquiry.response_first_reminder_escalation_sent_at.blank?
      ResponseReminderMailer.first_reminder_escalation(enquiry).deliver_later!
    end
  end

  def second_reminder_escalation(enquiry)
    if enquiry.response_second_reminder_escalation_sent_at.blank?
      ResponseReminderMailer.second_reminder_escalation(enquiry).deliver_later!
    end
  end
end


