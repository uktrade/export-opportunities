require 'rails_helper'

RSpec.describe SendEnquiriesReportToMatchingAdminUser, :elasticsearch, :commit, sidekiq: :inline do
  it 'generates a report with a few enquiries' do
    ActionMailer::Base.deliveries.clear

    enquiry = create(:enquiry, created_at: DateTime.new(2017, 12, 12, 13).in_time_zone(Time.zone))
    from_date = '13/1/2017'#DateTime.new(2017, 1, 1, 13).in_time_zone(Time.zone).to_s
    to_date = '1/1/2018'#DateTime.new(2018, 1, 1, 13).in_time_zone(Time.zone).to_s
    SendEnquiriesReportToMatchingAdminUser.new.perform('an@email.com', enquiry, from_date, to_date, 6000)

    last_delivery = ActionMailer::Base.deliveries.last

    expect(last_delivery.text_part.to_s).to include('Please find the Enquiries report')
    expect(last_delivery.attachments[0].filename).to eq('Enquiries.csv')
  end

  it 'generates a report with zipped file' do
    ActionMailer::Base.deliveries.clear

    enquiry = create_list(:enquiry, 3, created_at: DateTime.new(2017, 12, 12, 13).in_time_zone(Time.zone))
    from_date = '15/1/2017'#DateTime.new(2017, 1, 15, 13).in_time_zone(Time.zone)
    to_date = '31/1/2018' #DateTime.new(2018, 1, 31, 13).in_time_zone(Time.zone)
    SendEnquiriesReportToMatchingAdminUser.new.perform('an@email.com', enquiry, from_date, to_date, 2)

    last_delivery = ActionMailer::Base.deliveries.last

    expect(last_delivery.text_part.to_s).to include('Please find the Enquiries report')
    expect(valid_zip?(last_delivery.attachments[0].filename)).to eq(true)
  end

  it 'generates a report with 3 zipped files' do
    ActionMailer::Base.deliveries.clear

    allow_any_instance_of(SendEnquiriesReportToMatchingAdminUser).to receive(:zip_file_enquiries_cutoff_ses_limit).and_return(3)

    enquiry = create_list(:enquiry, 6, created_at: DateTime.new(2017, 12, 12, 13).in_time_zone(Time.zone))
    from_date = '15/1/2017'#DateTime.new(2017, 1, 15, 13).in_time_zone(Time.zone)
    to_date = '31/1/2018' #DateTime.new(2018, 1, 31, 13).in_time_zone(Time.zone)
    SendEnquiriesReportToMatchingAdminUser.new.perform('an@email.com', enquiry, from_date, to_date, 2)

    last_delivery = ActionMailer::Base.deliveries.last

    expect(last_delivery.text_part.to_s).to include('Please find the Enquiries report')
    expect(ActionMailer::Base.deliveries.count).to eq(3)
    expect(valid_zip?(last_delivery.attachments[0].filename)).to eq(true)
  end

  private 

    def valid_zip?(file)
      zip = Zip::File.open(file)
      true
    rescue StandardError
      false
    ensure
      zip&.close
    end
end
