class ResponseReminderMailerPreview < ActionMailer::Preview

  def first_reminder
    ResponseReminderMailer.first_reminder(enquiry)
  end

  def second_reminder
    ResponseReminderMailer.second_reminder(enquiry)
  end

  def first_reminder_escalation
    ResponseReminderMailer.first_reminder_escalation(enquiry)
  end

  def second_reminder_escalation
    ResponseReminderMailer.second_reminder_escalation(enquiry)
  end

  private

    def enquiry
      Enquiry.first_or_create(
        user: User.last,
        first_name: 'Elijah',
        last_name: 'Little',
        company_telephone: '1-115-334-4358',
        company_name: 'ilpert, Sanford and Abbott',
        company_address: '813 Reinger Dale',
        company_house_number: '1027',
        company_postcode: '55939-3068',
        existing_exporter: 'Not yet',
        company_sector: 'human resources',
        company_explanation: 'Business-focused bifurcated budgetary management',
        opportunity: Opportunity.last
      )
    end
end
