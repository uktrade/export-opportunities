require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe ResponseReminderMailer, type: :mailer do

  def mail
    ActionMailer::Base.deliveries.last
  end

  before do
    @enquiry = create(:enquiry)
  end

  it 'sends first_reminder' do
    expect do
      ResponseReminderMailer.first_reminder(@enquiry).deliver_now!
    end.to change{ @enquiry.response_first_reminder_sent_at }

    expect(mail.to).to include(@enquiry.opportunity.author.email)
    expect(mail.subject).to eql("1st reminder: respond to enquiry")
    expect(mail.reply_to).to include(Figaro.env.CONTACT_US_EMAIL)
    expect(mail.parts.first.body.raw_source).to include('1st reminder: respond to enquiry')
  end

  it 'sends second_reminder' do
    expect do
      ResponseReminderMailer.second_reminder(@enquiry).deliver_now!
    end.to change{ @enquiry.response_second_reminder_sent_at }

    expect(mail.to).to include(@enquiry.opportunity.author.email)
    expect(mail.subject).to eql("2nd reminder: respond to enquiry")
    expect(mail.reply_to).to include(Figaro.env.CONTACT_US_EMAIL)
    expect(mail.cc).to include(Figaro.env.LATE_RESPONSE_SUPPORT_INBOX)
    expect(mail.parts.first.body.raw_source).to include('2nd reminder: respond to enquiry')
  end

  it 'sends first_reminder_escalation' do
    expect do
      ResponseReminderMailer.first_reminder_escalation(@enquiry).deliver_now!
    end.to change{ @enquiry.response_first_reminder_escalation_sent_at }

    expect(mail.to).to include(Figaro.env.LATE_RESPONSE_ESCALATION_INBOX)
    expect(mail.subject).to eql("Response 21 days overdue")
    expect(mail.parts.first.body.raw_source).to include('Response 21 days overdue')
  end

  it 'sends second_reminder_escalation' do
    expect do
      ResponseReminderMailer.second_reminder_escalation(@enquiry).deliver_now!
    end.to change{ @enquiry.response_second_reminder_escalation_sent_at }

    expect(mail.to).to include(Figaro.env.LATE_RESPONSE_ESCALATION_INBOX)
    expect(mail.subject).to eql("Response 28 days overdue")
    expect(mail.parts.first.body.raw_source).to include('Response 28 days overdue')
  end

end