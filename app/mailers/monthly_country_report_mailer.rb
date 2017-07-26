class MonthlyCountryReportMailer < ApplicationMailer
  include Devise::Mailers::Helpers
  layout 'eig-email'

  def send_report(report_csv, current_user)
    # send report with CSV attachment to the admin user that is currently logged in.
    attachments['report.csv'] = report_csv
    mail(to: current_user, from: 'noreply@export.great.gov.uk', name: 'Export opportunities', subject: 'Your Report')
  end
end
