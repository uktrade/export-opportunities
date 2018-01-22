class EnquiriesReportMailer < ApplicationMailer
  include Devise::Mailers::Helpers
  layout 'eig-email'

  def send_report(report_csv, current_user, zip_file)
    if zip_file
      attachments[report_csv.to_s] = File.read(report_csv)
    else
      attachments['Enquiries.csv'] = report_csv
    end
    mail(to: current_user, from: Figaro.env.MAILER_FROM_ADDRESS!, name: 'Export opportunities', subject: 'Your Enquiries Report')
  end
end
