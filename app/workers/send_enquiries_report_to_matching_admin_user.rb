require 'matrix'
require 'csv'
require 'zip'

class SendEnquiriesReportToMatchingAdminUser
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(current_editor_email, enquiries, from_date, to_date, zip_file_enquiries_cutoff)
    @enquiries = Enquiry.where(id: enquiries)
    from_date = Date.strptime(from_date, '%d/%m/%Y')
    to_date = Date.strptime(to_date, '%d/%m/%Y')
    @enquiries = @enquiries.where(created_at: from_date..to_date)

    csv = EnquiryCSV.new(@enquiries)

    csv_file = []
    csv.each do |row|
      csv_file << row
    end
    if csv_file.length > zip_file_enquiries_cutoff.to_i

      header = csv_file[0]
      data = csv_file.drop(0)

      while data.length.positive?
        # generate a unique temp filename for zipping
        zipped_filename = 'enquiries_' + current_editor_email.gsub(/[^0-9A-Za-z]/, '') + '_' + Time.new.to_i.to_s + '_' + data.length.to_i.to_s

        Zip::File.open(zipped_filename + '.zip', Zip::File::CREATE) do |zipfile|
          zipfile.get_output_stream(zipped_filename + '.csv') { |f| f.puts [header] + data.shift(zip_file_enquiries_cutoff_ses_limit) }
        end

        EnquiriesReportMailer.send_report(zipped_filename + '.zip', current_editor_email, true).deliver_later!
      end
    else
      EnquiriesReportMailer.send_report(csv_file, current_editor_email, false).deliver_later!
    end
  end

  def zip_file_enquiries_cutoff_ses_limit
    ENV.fetch('zip_file_enquiries_cutoff', '6000').to_i
  end
end
