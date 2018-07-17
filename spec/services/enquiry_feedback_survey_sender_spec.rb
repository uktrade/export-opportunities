require 'rails_helper'

RSpec.describe EnquiryFeedbackSurveySender do
  describe 'start_date and end_date' do
    it 'selects enquiries from a given date range, not inclusive' do
      yesterday = Time.zone.now.beginning_of_day - 1.day
      opp = create(:opportunity, response_due_on: yesterday - 3.months)
      enquiries_in_range = [
        create(:enquiry, opportunity: opp, created_at: yesterday),
        create(:enquiry, opportunity: opp, created_at: yesterday + 12.hours),
        create(:enquiry, opportunity: opp, created_at: yesterday + 1.day),
      ]

      enquiries_not_in_range = [
        create(:enquiry, created_at: yesterday - 1.second),
        create(:enquiry, created_at: yesterday + 1.day + 1.second),
        create(:enquiry, created_at: yesterday - 3.months),
      ]

      returned = EnquiryFeedbackSurveySender.new.call
      expect(returned).to include(*enquiries_in_range.map(&:id))
      expect(returned).not_to include(*enquiries_not_in_range.map(&:id))
    end
  end

  it 'does not return enquiries whose authors have opted out of emails' do
    date_to_sample = Time.zone.now.beginning_of_day - 3.months - 1.day
    user = create(:user, email: 'opt-out@example.com')
    opp = create(:opportunity, response_due_on: date_to_sample)

    create(:feedback_opt_out, user: user)
    create(:enquiry, user: user, opportunity: opp, created_at: date_to_sample)
    vanilla_enquiry = create(:enquiry, opportunity: opp, created_at: date_to_sample)

    returned = EnquiryFeedbackSurveySender.new.call

    expect(returned.size).to be 1
    expect(returned).to include vanilla_enquiry.id
  end

  it 'dispatches the matched enquiries to EnquiryFeedbackSender' do
    yesterday = Time.zone.now.beginning_of_day - 1.day
    opp = create(:opportunity, response_due_on: yesterday - 3.months)

    first_matched_enquiry = create(:enquiry, created_at: yesterday, opportunity: opp)
    second_matched_enquiry = create(:enquiry, created_at: yesterday + 1.day, opportunity: opp)

    expect_any_instance_of(EnquiryFeedbackSender).to receive(:call).with(first_matched_enquiry.id).once
    expect_any_instance_of(EnquiryFeedbackSender).to receive(:call).with(second_matched_enquiry.id).once

    EnquiryFeedbackSurveySender.new.call
  end
end
