require 'rails_helper'

RSpec.describe SendEnquiriesReportToMatchingAdminUser, :elasticsearch, :commit, sidekiq: :inline do
  it 'generates a report with a few enquiries' do
    enquiry = create(:enquiry, created_at: DateTime.new(2017, 12, 12, 13).in_time_zone(Time.zone))
    from_date = DateTime.new(2017, 1, 1, 13).in_time_zone(Time.zone)
    to_date = DateTime.new(2018, 1, 1, 13).in_time_zone(Time.zone)
    SendEnquiriesReportToMatchingAdminUser.new.perform('an@email.com', enquiry, from_date, to_date, false)

    last_delivery = ActionMailer::Base.deliveries.last

    expect(last_delivery.text_part.to_s).to include('Please find the Enquiries report attached.')
    expect(last_delivery.attachments[0].filename).to eq('Enquiries.csv')
  end

  it 'generates a report with zipped file' do
    enquiry = create_list(:enquiry, 3, created_at: DateTime.new(2017, 12, 12, 13).in_time_zone(Time.zone))
    from_date = DateTime.new(2017, 1, 15, 13).in_time_zone(Time.zone)
    to_date = DateTime.new(2018, 1, 31, 13).in_time_zone(Time.zone)
    SendEnquiriesReportToMatchingAdminUser.new.perform('an@email.com', enquiry, from_date, to_date, true)

    last_delivery = ActionMailer::Base.deliveries.last

    expect(last_delivery.text_part.to_s).to include('Please find the Enquiries report attached.')
    # expect(last_delivery.attachments[0].filename).to eq('Enquiries.zip')
    expect(valid_zip?(last_delivery.attachments[0].filename)).to eq(true)
  end

  private def valid_zip?(file)
    zip = Zip::File.open(file)
    true
  rescue StandardError
    false
  ensure
    zip&.close
  end
end
