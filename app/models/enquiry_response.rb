class EnquiryResponse < ApplicationRecord
  include EnquiryResponseHelper

  validate :email_body_length_check
  validates :enquiry_id, uniqueness: true

  belongs_to :enquiry
  belongs_to :editor

  def email_body_length_check
    return unless email_body.empty? && response_type <= 3

    errors.add(:email_body, 'Please add a comment.')
  end

  def response_type_to_human
    to_h(response_type)
  end

  def documents_list
    return 'Not available' if documents.nil? || response_type != 1

    begin
      docs = JSON.parse(documents)

      docs.each_with_object([]) do |document, file_list|
        file_list << document['result']['id']['original_filename'] + ' '
      end.join
    rescue JSON::ParserError
      'not available'
    end
  end
end
