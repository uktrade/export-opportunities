class MonthlyCountryReportMailer < ApplicationMailer
  include Devise::Mailers::Helpers

  def send_report(report_csv, current_user)
    # send report with CSV attachment to the user that requested it.
    attachments['report.csv'] = report_csv
    mail(from: 'noreply@export.great.gov.uk', name:'Export opportunities', subject:'Your Report', to: current_user)
  end
end
