class EnquiryResponse < ActiveRecord::Base
  attr_accessor :email_attachment

  has_attached_file :email_attachment
  validates_attachment_file_name :email_attachment, matches: [/ppt\Z/, /pptx\Z/, /pdf\Z/, /doc\Z/, /docx\Z/, /xls\Z/, /xlsx\Z/, /txt\Z/]
  validates_attachment_size :email_attachment, in: 10.bytes..25.megabytes
  validates :email_body, length: { minimum: 30, message: 'You need at least 30 characters in your reply' }
  belongs_to :enquiry
  belongs_to :editor
  before_save :scan_attachment

  def scan_attachment
    attachment = email_attachment.queued_for_write[:original]
    is_file_clean_or_no_file = if attachment
                                 ApplicationController.helpers.scan_clean?(attachment.path)
                               else
                                 true
                               end
    errors.add(:virus_scanner, 'Your attachment is INFECTED. Please contact Export Opportunities helpdesk immediately') unless is_file_clean_or_no_file
  end
end
