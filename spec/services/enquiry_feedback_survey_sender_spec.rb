require 'rails_helper'

RSpec.describe EnquiryFeedbackSurveySender do
  describe 'start_date and end_date' do
    it 'selects enquiries from a given date range, not inclusive' do
      yesterday = Time.zone.now.beginning_of_day - 1.day
      enquiries_in_range = [
        create(:enquiry, created_at: yesterday),
        create(:enquiry, created_at: yesterday + 12.hours),
        create(:enquiry, created_at: yesterday + 1.day),
      ]

      enquiries_not_in_range = [
        create(:enquiry, created_at: yesterday - 1.second),
        create(:enquiry, created_at: yesterday + 1.day + 1.second),
        create(:enquiry, created_at: yesterday - 1.year),
      ]

      returned = EnquiryFeedbackSurveySender.new.call
      expect(returned).to include(*enquiries_in_range.map(&:id))
      expect(returned).not_to include(*enquiries_not_in_range.map(&:id))
    end
  end

  it 'does not return enquiries whose authors have opted out of emails' do
    date_to_sample = Time.zone.now.beginning_of_day - 1.day
    user = create(:user, email: 'opt-out@example.com')

    create(:feedback_opt_out, user: user)
    create(:enquiry, user: user, created_at: date_to_sample)
    vanilla_enquiry = create(:enquiry, created_at: date_to_sample)

    returned = EnquiryFeedbackSurveySender.new.call

    expect(returned.size).to be 1
    expect(returned).to include vanilla_enquiry.id
  end

  it 'dispatches the matched enquiries to EnquiryFeedbackSender' do
    yesterday = Time.zone.now.beginning_of_day - 1.day
    first_matched_enquiry = create(:enquiry, created_at: yesterday)
    second_matched_enquiry = create(:enquiry, created_at: yesterday + 1.day)

    expect_any_instance_of(EnquiryFeedbackSender).to receive(:call).with(first_matched_enquiry.id).once
    expect_any_instance_of(EnquiryFeedbackSender).to receive(:call).with(second_matched_enquiry.id).once

    EnquiryFeedbackSurveySender.new.call
  end
end
