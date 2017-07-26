require 'rails_helper'

RSpec.describe CreateReportAudit do
  before do
    @user = create(:editor)
    @params = { impact_stats_date_data_3i: 23, impact_stats_date_data_2i: 6, impact_stats_date_data_1i: 2015 }.to_json
    @report_audit = class_double('ReportAudit')
    allow(@report_audit).to receive(:create!)
    stub_const('ReportAudit', @report_audit)
  end

  describe '#call' do
    it 'creates a report audit with a user' do
      skip
      expect(@report_audit).to receive(:new).with(no_args)

      CreateReportAudit.new.call(@user, 'fake_action', @params)
    end
  end
end
