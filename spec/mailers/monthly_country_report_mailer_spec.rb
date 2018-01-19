require 'rails_helper'
require 'capybara/email/rspec'
require 'csv'

RSpec.describe MonthlyCountryReportMailer, type: :mailer do
  describe '.send_report' do
    it 'sends a monthly report to the editor who is currently logged in' do
      report_csv = []
      editor = create(:editor, role: :administrator)
      report_csv << CSV.generate_line(['sample row'])
      MonthlyCountryReportMailer.send_report(report_csv, editor.email).deliver_now!
      last_delivery = ActionMailer::Base.deliveries.last

      expect(last_delivery.html_part.to_s).to include('Please find the Monthly Outcomes against Targets report attached.')
      expect(last_delivery.to). to include(editor.email)
      expect(last_delivery.from). to include(Figaro.env.MAILER_FROM_ADDRESS!)
      expect(last_delivery.subject). to include('Your Report')
    end
  end
end
