require 'rails_helper'

RSpec.describe EnquiryFeedbackSurveySender do
  describe 'start_date and end_date' do
    it 'selects enquiries from a given date range, not inclusive' do
      enquiries_in_range = [
        create(:enquiry, created_at: Time.zone.local(1990, 2, 10)),
        create(:enquiry, created_at: Time.zone.local(1990, 2, 12)),
        create(:enquiry, created_at: Time.zone.local(1990, 2, 20)),
      ]

      enquiries_not_in_range = [
        create(:enquiry, created_at: Time.zone.local(1990, 2, 1)),
        create(:enquiry, created_at: Time.zone.local(1990, 2, 2)),
        create(:enquiry, created_at: Time.zone.local(1990, 2, 3)),
      ]

      returned = EnquiryFeedbackSurveySender.new.call(
        start_date: Time.zone.local(1990, 2, 10),
        end_date: Time.zone.local(1990, 2, 20),
        sample_size: 3
      )

      expect(returned).to include(*enquiries_in_range)
      expect(returned).not_to include(*enquiries_not_in_range)
    end
  end

  describe 'sample_size' do
    it 'specifies the maximum number of enquiries to find' do
      create_list(:enquiry, 2, created_at: Time.zone.local(1990, 2, 11))

      returned = EnquiryFeedbackSurveySender.new.call(
        start_date: Time.zone.local(1990, 2, 10),
        end_date: Time.zone.local(1990, 2, 20),
        sample_size: 1
      )

      expect(returned.size).to be 1
    end
  end

  it 'only returns enquiries without prior feedback requests' do
    date_to_sample = Time.zone.local(1990, 2, 11)

    already_responded = create(:enquiry, created_at: date_to_sample)
    create(:enquiry_feedback, enquiry: already_responded)
    enquiry_without_prior_feedback_request = create(:enquiry, created_at: date_to_sample)

    returned = EnquiryFeedbackSurveySender.new.call(
      start_date: date_to_sample,
      end_date: date_to_sample,
      sample_size: 2
    )

    expect(returned.size).to be 1
    expect(returned).to include enquiry_without_prior_feedback_request
  end

  it 'only returns one enquiry per email address' do
    date_to_sample = Time.zone.local(1990, 2, 11)

    user = create(:user, email: 'duplicated@example.com')
    create(:enquiry, created_at: date_to_sample, user: user)
    create(:enquiry, created_at: date_to_sample, user: user)

    returned = EnquiryFeedbackSurveySender.new.call(
      start_date: date_to_sample,
      end_date: date_to_sample,
      sample_size: 2
    )

    expect(returned.size).to be 1
  end

  it 'does not return enquiries whose authors have opted out of emails' do
    date_to_sample = Time.zone.local(1990, 2, 11)
    user = create(:user, email: 'opt-out@example.com')

    create(:feedback_opt_out, user: user)
    create(:enquiry, user: user, created_at: date_to_sample)
    vanilla_enquiry = create(:enquiry, created_at: date_to_sample)

    returned = EnquiryFeedbackSurveySender.new.call(
      start_date: date_to_sample,
      end_date: date_to_sample,
      sample_size: 2
    )

    expect(returned.size).to be 1
    expect(returned).to include vanilla_enquiry
  end

  it 'dispatches the matched enquiries to EnquiryFeedbackSender' do
    first_matched_enquiry = create(:enquiry, created_at: Time.zone.local(1990, 10, 10))
    second_matched_enquiry = create(:enquiry, created_at: Time.zone.local(1990, 10, 10))

    expect_any_instance_of(EnquiryFeedbackSender).to receive(:call).with(first_matched_enquiry).once
    expect_any_instance_of(EnquiryFeedbackSender).to receive(:call).with(second_matched_enquiry).once

    EnquiryFeedbackSurveySender.new.call(
      start_date: Time.zone.local(1990, 10, 10),
      end_date: Time.zone.local(1990, 10, 10),
      sample_size: 2
    )
  end
end
