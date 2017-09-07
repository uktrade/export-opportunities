class EnquiryResponse < ActiveRecord::Base
  mount_uploaders :attachments, EnquiryResponseUploader
  attr_accessor :signature, :completed_at
  # default_scope { where.not(completed_at: nil) }

  # TODO: add validations
  # validates_attachment_file_name :attachment, matches: [/ppt\Z/, /pptx\Z/, /pdf\Z/, /doc\Z/, /docx\Z/, /xls\Z/, /xlsx\Z/, /txt\Z/]
  # validates_attachment_size :attachment, in: 10.bytes..25.megabytes
  validate :email_body_length_check
  # validate :email_attachment_filesize_check
  # TODO: scan for viruses
  # before_save :scan_attachment

  belongs_to :enquiry
  belongs_to :editor

  def email_body_length_check
    if email_body.empty? && response_type <= 3
      errors.add(:email_body, 'Please add a comment.')
    end
  end

  def scan_attachment
    attachment = attachments.queued_for_write[:original]
    if attachment
      ApplicationController.helpers.scan_clean?(attachments.path)
    else
      errors.add(:virus_scanner, 'Your attachment is INFECTED. Please contact Export Opportunities helpdesk immediately') unless is_file_clean_or_no_file
    end
  end

  def response_type_to_human
    case response_type
    when 1
      'Won'
    when 2
      'Need more information'
    when 3
      'Did not win'
    when 4
      'Not UK registered'
    when 5
      'Not for third party'
    end
  end

  def documents_list
    return 'Not available' unless response_type == 1
    file_list = ''
    begin
      docs = JSON.parse(documents)
      docs.each do |document|
        file_list << document['result']['id']['original_filename'] + ' '
      end
      return file_list
    rescue JSON::ParserError
      return 'not available'
    end
  end
end
