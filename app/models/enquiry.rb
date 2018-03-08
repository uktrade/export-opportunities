class Enquiry < ApplicationRecord
  belongs_to :opportunity, counter_cache: :enquiries_count, required: true
  belongs_to :user
  has_one :enquiry_response
  attr_accessor :status
  attr_accessor :response_status

  # enquiry feedback is the response from users at the impact email links
  has_one :feedback, class_name: 'EnquiryFeedback'
  # enquiry response is the response a post will provide back to the enquiry from the admin centre
  has_one :enquiry_response

  COMPANY_EXPLANATION_MAXLENGTH = 1100.freeze
  EXISTING_EXPORTER_CHOICES = [
    'Not yet',
    'Yes, in the last year',
    'Yes, 1-2 years ago',
    'Yes, over 2 years ago',
  ].freeze

  validates :first_name, :last_name, :company_telephone, \
    :company_name, :company_address, :company_postcode, \
    :existing_exporter, :company_sector, :company_explanation, \
    presence: true

  validate :company_explanation_length

  def company_explanation_length
    company_explanation_text = self.company_explanation
    errors.add(:company_explanation, 'Company explanation is too long (maximum is 1100 characters)') if company_explanation_text.scan(/./).count > COMPANY_EXPLANATION_MAXLENGTH
  end

  delegate :email, to: :user

  paginates_per 25

  scope :sent, -> { where.not(completed_at: nil) }

  def self.initialize_from_existing(old_enquiry)
    return Enquiry.new unless old_enquiry
    Enquiry.new(old_enquiry.attributes.except('company_explanation', 'id'))
  end

  def company_url
    # Data may not include a scheme/protocol so we must be careful when creating
    # links that Rails doesn't make them incorrectly relative.
    Addressable::URI.heuristic_parse(self[:company_url]).to_s
  rescue Addressable::URI::InvalidURIError
    self[:company_url].to_s
  end

  def response_status
    if enquiry_response
      unless enquiry_response['completed_at']
        Rails.logger.error("message not sent: #{enquiry_response.inspect}")
        return 'Pending'
      end

      delta_enquiry_response = enquiry_response['completed_at'] - created_at
      delta_enquiry_response_days = delta_enquiry_response / 86_400
      days_word = if delta_enquiry_response_days.floor.zero? || delta_enquiry_response_days.floor > 1
                    'days'
                  else
                    'day'
                  end
      'Replied ' + delta_enquiry_response_days.floor.to_s + ' ' + days_word + ' after'
    else
      delta_enquiry = Time.zone.now - created_at
      days_left = ((7 * 86_400 - delta_enquiry).abs / 86_400).round
      days_word = if days_left.zero? || days_left > 1
                    'days'
                  else
                    'day'
                  end
      if delta_enquiry < 7 * 86_400
        days_left.to_s + ' ' + days_word + ' left'
      else
        days_left.to_s + ' ' + days_word + ' overdue'
      end
    end
  end
end
