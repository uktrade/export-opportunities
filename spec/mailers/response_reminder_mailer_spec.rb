require 'rails_helper'
require 'capybara/email/rspec'

RSpec.describe ResponseReminderMailer, type: :mailer do

  def mail
    ActionMailer::Base.deliveries.last
  end

  def count
    ActionMailer::Base.deliveries.count
  end

  before do
    @enquiry = create(:enquiry)
  end

  it 'sends reminder' do
    expect(@enquiry.opportunity.contacts.any?).to be_truthy
    expect do
      ResponseReminderMailer.reminder(@enquiry).deliver_now!
    end.to change{ @enquiry.response_reminder_sent_at }

    expect(mail.to).to eq(@enquiry.opportunity.contacts.pluck(:email))
    expect(mail.subject).to eql("First reminder: Respond to enquiry")
    expect(mail.reply_to).to include(Figaro.env.CONTACT_US_EMAIL)
    expect(mail.parts.first.body.raw_source).to include('First reminder')
  end

  it 'does not send reminder if contacts blank' do
    @enquiry.opportunity.contacts.destroy_all
    expect do
      ResponseReminderMailer.reminder(@enquiry).deliver_now!
    end.to_not change{ count }
  end
end

# Not yet used but likely in time, so leaving here [8 Jan 2019]
# it 'sends second_reminder' do
#   expect do
#     ResponseReminderMailer.second_reminder(@enquiry).deliver_now!
#   end.to change{ @enquiry.response_second_reminder_sent_at }

#   expect(mail.to).to include(@enquiry.opportunity.author.email)
#   expect(mail.subject).to eql("2nd reminder: respond to enquiry")
#   expect(mail.reply_to).to include(Figaro.env.CONTACT_US_EMAIL)
#   expect(mail.cc).to include(Figaro.env.LATE_RESPONSE_SUPPORT_INBOX)
#   expect(mail.parts.first.body.raw_source).to include('2nd reminder: respond to enquiry')
# end

# it 'sends first_reminder_escalation' do
#   expect do
#     ResponseReminderMailer.first_reminder_escalation(@enquiry).deliver_now!
#   end.to change{ @enquiry.response_first_reminder_escalation_sent_at }

#   expect(mail.to).to include(Figaro.env.LATE_RESPONSE_ESCALATION_INBOX)
#   expect(mail.subject).to eql("Response 21 days overdue")
#   expect(mail.parts.first.body.raw_source).to include('Response 21 days overdue')
# end

# it 'sends second_reminder_escalation' do
#   expect do
#     ResponseReminderMailer.second_reminder_escalation(@enquiry).deliver_now!
#   end.to change{ @enquiry.response_second_reminder_escalation_sent_at }

#   expect(mail.to).to include(Figaro.env.LATE_RESPONSE_ESCALATION_INBOX)
#   expect(mail.subject).to eql("Response 28 days overdue")
#   expect(mail.parts.first.body.raw_source).to include('Response 28 days overdue')
# end