require 'rails_helper'

RSpec.describe SendOpportunitiesDigest, :elasticsearch, :commit, sidekiq: :inline do
  it 'creates a valid object with one notification to send' do
    ActionMailer::Base.deliveries.clear

    notification_creation_timestamp = Time.zone.now - 1.day + 3.hours
    user = create(:user)
    subscription = create(:subscription, user: user)
    opportunity = create(:opportunity, :published)
    subscription_notification = create(:subscription_notification, subscription: subscription, opportunity: opportunity, created_at: notification_creation_timestamp)
    SendOpportunitiesDigest.new.perform

    # enquiry = create(:enquiry, created_at: DateTime.new(2017, 12, 12, 13).in_time_zone(Time.zone))
    # from_date = '13/1/2017'#DateTime.new(2017, 1, 1, 13).in_time_zone(Time.zone).to_s
    # to_date = '1/1/2018'#DateTime.new(2018, 1, 1, 13).in_time_zone(Time.zone).to_s
    # SendEnquiriesReportToMatchingAdminUser.new.perform('an@email.com', enquiry, from_date, to_date, 6000)
    #
    # last_delivery = ActionMailer::Base.deliveries.last
    #
    # expect(last_delivery.text_part.to_s).to include('Please find the Enquiries report')
    # expect(last_delivery.attachments[0].filename).to eq('Enquiries.csv')
  end

end
