require 'matrix'
require 'csv'
require 'zip'
require 'tempfile'

class SendEnquiriesReportToMatchingAdminUser < ActiveJob::Base
  sidekiq_options retry: false

  def perform(current_editor_email, enquiries, from_date, to_date, zip_file_enquiries_cutoff)
    @enquiries = Enquiry.where(id: enquiries)
    from_date = Date.strptime(from_date.to_s, '%d/%m/%Y')
    to_date = Date.strptime(to_date.to_s, '%d/%m/%Y')
    @enquiries = @enquiries.where(created_at: from_date..to_date)

    csv = EnquiryCSV.new(@enquiries)

    # Count the number of rows to determine if we need to zip
    row_count = 1 # Start with 1 for the header
    @enquiries.find_each { row_count += 1 }

    if row_count > zip_file_enquiries_cutoff.to_i
      # Process in chunks to avoid loading everything into memory
      process_in_chunks(csv, current_editor_email, zip_file_enquiries_cutoff_ses_limit)
    else
      # For smaller datasets, collect the CSV content
      csv_content = ""
      csv.each do |row|
        csv_content << row
      end

      # Send the CSV content directly
      EnquiriesReportMailer.send_report(csv_content, current_editor_email, false).deliver_later!
    end
  end

  def process_in_chunks(csv, current_editor_email, chunk_size)
    # Get the header first
    header = nil
    csv_enumerator = csv.each
    header = csv_enumerator.next if csv_enumerator.respond_to?(:next)

    # Process in chunks
    chunk_counter = 0

    # Generate a base filename
    base_filename = 'enquiries_' + current_editor_email.gsub(/[^0-9A-Za-z]/, '') + '_' + Time.now.to_i.to_s

    # Create a temporary directory for our files
    temp_dir = Dir.mktmpdir

    begin
      current_file = File.join(temp_dir, "#{base_filename}_#{chunk_counter}.csv")
      current_zip = File.join(temp_dir, "#{base_filename}_#{chunk_counter}.zip")

      File.open(current_file, 'w') do |file|
        # Write the header
        file.write(header) if header

        # Write rows in batches
        row_counter = 0
        csv_enumerator.each do |row|
          file.write(row)
          row_counter += 1

          # If we've reached the chunk size, zip and send
          if row_counter >= chunk_size
            file.close

            # Create zip file
            Zip::File.open(current_zip, Zip::File::CREATE) do |zipfile|
              zipfile.add(File.basename(current_file), current_file)
            end

            # Send the email
            EnquiriesReportMailer.send_report(current_zip, current_editor_email, true).deliver_later!

            # Prepare for the next chunk
            chunk_counter += 1
            current_file = File.join(temp_dir, "#{base_filename}_#{chunk_counter}.csv")
            current_zip = File.join(temp_dir, "#{base_filename}_#{chunk_counter}.zip")

            # Start a new file with the header
            file = File.open(current_file, 'w')
            file.write(header) if header
            row_counter = 0
          end
        end
      end

      # Send the last chunk if it has any data
      if File.size?(current_file) && File.size(current_file) > (header ? header.length : 0)
        Zip::File.open(current_zip, Zip::File::CREATE) do |zipfile|
          zipfile.add(File.basename(current_file), current_file)
        end

        EnquiriesReportMailer.send_report(current_zip, current_editor_email, true).deliver_later!
      end
    ensure
      # Clean up temporary files
      FileUtils.remove_entry(temp_dir) if temp_dir
    end
  end

  def zip_file_enquiries_cutoff_ses_limit
    Figaro.env.zip_file_enquiries_cutoff ? Figaro.env.zip_file_enquiries_cutoff!.to_i : 6000
  end
end
