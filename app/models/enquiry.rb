class Enquiry < ActiveRecord::Base
  belongs_to :opportunity, counter_cache: :enquiries_count, required: true
  belongs_to :user
  # enquiry response is the response a post will provide back to the enquiry from the admin centre
  has_one :response, class_name: 'EnquiryResponse'
  # enquiry feedback is the response from users at the impact email links
  has_one :feedback, class_name: 'EnquiryFeedback'

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

  validates :company_explanation, length: { maximum: COMPANY_EXPLANATION_MAXLENGTH }

  delegate :email, to: :user

  paginates_per 25

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
end
