require 'matrix'
require 'csv'
require 'zip'

class SendEnquiriesReportToMatchingAdminUser
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(current_editor_email, enquiries, from_date, to_date, zip_file)
    @enquiries = Enquiry.where(id: enquiries)
    from_date = Date.strptime(from_date, '%d/%m/%Y')
    to_date = Date.strptime(to_date, '%d/%m/%Y')
    @enquiries = @enquiries.where(created_at: from_date..to_date)

    csv = EnquiryCSV.new(@enquiries)

    csv_file = []
    csv.each do |row|
      csv_file << row
    end
    if zip_file || @enquiries.size > 6000

      # generate a unique temp filename for zipping
      zipped_filename = 'enquiries_' + current_editor_email.gsub(/[^0-9A-Za-z]/, '') + '_' + Time.new.to_i.to_s

      Zip::File.open(zipped_filename + '.zip', Zip::File::CREATE) do |zipfile|
        zipfile.get_output_stream(zipped_filename + '.csv') { |f| f.puts csv_file }
      end

      EnquiriesReportMailer.send_report(zipped_filename + '.zip', current_editor_email, true).deliver_later!
    else
      EnquiriesReportMailer.send_report(csv_file, current_editor_email, false).deliver_later!
    end
  end
end
