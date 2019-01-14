require 'rails_helper'

RSpec.describe SendEnquiryResponseReminders, sidekiq: :inline do

  def count
    ActionMailer::Base.deliveries.count
  end

  def last_email
    ActionMailer::Base.deliveries.last.subject
  end

  def run
    SendEnquiryResponseReminders.new.perform
  end

  describe 'filters to correct enquiries' do
    before(:each) do
      Opportunity.destroy_all
      ActionMailer::Base.deliveries.clear
      @opportunity = create(:opportunity, status: :publish,
                            response_due_on: 2.months.from_now)
      @opportunity.enquiries << @enquiry = create(:enquiry)
      Timecop.freeze(Time.now + 10.days + 1.minute)
    end
    after(:each) do
      Timecop.return
    end

    it 'runs correctly' do
      run
      expect(count).to eq(1)
      expect(last_email).to include("First reminder:")
    end
    it 'only where opportunities are published' do
      @opportunity.update(status: :draft)
      run
      expect(count).to eq(0)
    end
    it 'only where opportunities response is not due' do
      @opportunity.update(response_due_on: 1.day.ago)
      run
      expect(count).to eq(0)
    end
    it 'only where completed response not already given' do
      EnquiryResponse.destroy_all
      # Creates an complete response - should NOT send reminder
      response = create(:enquiry_response, enquiry: @enquiry)
      run
      expect(count).to eq(0)

      # Now revert to if response uncompleted - SHOULD send 
      response.update(completed_at: nil)
      run
      expect(count).to eq(1)
      
      # Clean up
      response.delete
    end
    it 'enquiries in last 30 days' do
      @enquiry.update(created_at: 1.year.ago)
      run
      expect(count).to eq(0)
    end
  end


  it "sends correct emails at the correct times, and only once each" do
    Enquiry.destroy_all
    ActionMailer::Base.deliveries.clear
    opportunity = create(:opportunity, status: :publish,
                            response_due_on: 2.months.from_now)
    opportunity.enquiries << create(:enquiry)

    # Step through the 32 days
    9.times do |x|
      Timecop.freeze(Time.now + x.days + 1.minute) do
        run
        # 1st email
        if x == 6
          expect(count).to eq(0)
        end
        if x == 7
          expect(count).to eq(1)
          expect(last_email).to include("First reminder:")
        end
        if x == 8
          expect(count).to eq(1)
          expect(last_email).to include("First reminder:")
        end
      end
    end
  end
end

# Code for proposed emails 2, 3 and 4.
# Not yet used but likely in time, so leaving here [8 Jan 2019]
#
# # 2nd email
# if x == 13
#   expect(count).to eq(1)
#   expect(last_email).to include("First reminder:")
# end
# if x == 14
#   expect(count).to eq(2)
#   expect(last_email).to include("2nd reminder:")
# end
# if x == 15
#   expect(count).to eq(2)
#   expect(last_email).to include("2nd reminder:")
# end
# # 3rd email
# if x == 20
#   expect(count).to eq(2)
#   expect(last_email).to include("2nd reminder:")
# end
# if x == 21
#   expect(count).to eq(3)
#   expect(last_email).to include("Response 21 days overdue")
# end
# if x == 22
#   expect(count).to eq(3)
#   expect(last_email).to include("Response 21 days overdue")
# end
# # 4th email
# if x == 27
#   expect(count).to eq(3)
#   expect(last_email).to include("Response 21 days overdue")
# end
# if x == 28
#   expect(count).to eq(4)
#   expect(last_email).to include("Response 28 days overdue")
# end
# if x == 29
#   expect(count).to eq(4)
#   expect(last_email).to include("Response 28 days overdue")
# end
