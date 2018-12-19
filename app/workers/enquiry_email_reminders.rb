# coding: utf-8

class EnquiryEmailReminders
  REMINDER_INTERVAL_DAYS = 7

  def perform
    # 1. Get all enquiries created after specific date.
    enquiries_all = Enquiry.where("created_at >= '#{Figaro.env.PTU_REMINDER_IMPLEMENTATION_DATE}'")

    # 2. Filter out those that have a response.
    enquiry_reminders = []
    enquiries_all.each do |enquiry|
      next if enquiry.enquiry_response.present?
      number = reminder_number(enquiry)

      # Currently only sending one initial reminder.
      # Alter if we decide to send 1st, 2nd, 3rd... reminders.
      next if number != 1
      enquiry_reminders.push(enquiry: enquiry, number: number)
    end

    # 3. Send reminder email for those without a reponse.
    EnquiryMailer.reminders(enquiry_reminders)
  end

  private def reminder_number(enquiry)
    number = -1
    days = (Time.zone.today - enquiry.created_at.to_date)
    number = days.numerator if days.denominator == 1
    number
  end
end
