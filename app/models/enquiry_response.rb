class EnquiryResponse < ApplicationRecord
  include EnquiryResponseHelper
  mount_uploaders :documents, EnquiryResponseUploader

  validate :email_body_length_check
  validates :enquiry_id, uniqueness: true

  belongs_to :enquiry
  belongs_to :editor

  def email_body_length_check
    if email_body.empty? && response_type <= 3
      errors.add(:email_body, 'Please add a comment.')
    end
  end

  def response_type_to_human
    to_h(response_type)
  end

  def documents_list
    return 'Not available' unless response_type == 1

    file_list = ''
    begin
      docs = JSON.parse(documents || '')
      docs.each do |document|
        file_list << document['result']['id']['original_filename'] + ' '
      end
      file_list
    rescue JSON::ParserError
      'not available'
    end
  end
end
