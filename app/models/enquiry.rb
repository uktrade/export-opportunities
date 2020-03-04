class Enquiry < ApplicationRecord
  belongs_to :opportunity, counter_cache: :enquiries_count, optional: false
  belongs_to :user
  attr_accessor :status

  # enquiry feedback is the response from users at the impact email links
  has_one :feedback, class_name: 'EnquiryFeedback', dependent: :nullify

  # enquiry response is the response a post will provide back to the enquiry from the admin centre
  has_one :enquiry_response, dependent: :nullify

  COMPANY_EXPLANATION_MAXLENGTH = 1100.freeze
  EXISTING_EXPORTER_CHOICES = [
    'Not yet',
    'Yes, in the last year',
    'Yes, 1-2 years ago',
    'Yes, over 2 years ago',
  ].freeze

  validates :first_name, \
            :company_name, :company_address, :company_postcode, \
            :existing_exporter, :company_sector, :company_explanation, \
            presence: true

  validate :company_explanation_length

  def company_explanation_length
    errors.add(:company_explanation, t('admin.enquiry.maximum_length')) if company_explanation && company_explanation.scan(/./).count > COMPANY_EXPLANATION_MAXLENGTH
  end

  delegate :email, to: :user

  paginates_per 25

  scope :sent, -> { where.not(completed_at: nil) }

  def self.new_from_sso(sso_id)
    enquiry = Enquiry.new
    unless Figaro.env.bypass_sso?
      enquiry.add_sso_data(sso_id)
      enquiry.add_directory_api_data(sso_id)
    end
    enquiry.set_enquiry_form_defaults
    enquiry
  end

  def add_sso_data(sso_id)
    if (sso_data = DirectoryApiClient.user_data(sso_id))
      profile = value_by_key(sso_data, :user_profile)
      if profile.present?
        assign_attributes(
          first_name: value_by_key(profile, :first_name),
          last_name: value_by_key(profile, :last_name),
          job_title: value_by_key(profile, :job_title),
          company_telephone: value_by_key(profile, :mobile_phone_number)
        )
      end
    end
  end

  def add_directory_api_data(sso_id)
    if (data = DirectoryApiClient.private_company_data(sso_id)).present?
      # company_type can be: COMPANIES_HOUSE, CHARITY,
      # PARTNERSHIP, SOLE_TRADER and OTHER.
      assign_attributes(
        company_telephone: company_telephone.presence ||
          value_by_key(data, :mobile_number),
        company_name: value_by_key(data, :name),
        company_address: [value_by_key(data, :address_line_1),
                          value_by_key(data, :address_line_2),
                          value_by_key(data, :country)].reject(&:blank?).join(' '),
        company_postcode: value_by_key(data, :postal_code),
        company_house_number: value_by_key(data, :number),
        company_url: value_by_key(data, :website),
        company_explanation: value_by_key(data, :summary),
        account_type: value_by_key(data, :company_type)
      )
    end
  end

  def set_enquiry_form_defaults
    # Add default values to prevent errors from empty string
    # data being put into required read-only fields
    unless individual?
      self.company_name = company_name.presence || 'No company name in Business Profile'
      self.company_address = company_address.presence || 'No company address in Business Profile'
      self.company_postcode = company_postcode.presence || 'No company post code in Business Profile'
      unless account_type == 'SOLE_TRADER'
        self.company_house_number = company_house_number.presence || 'No company number in Business Profile'
      end
    end
  end

  def individual?
    ['OTHER', nil, ''].include? account_type
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
      if enquiry_response['completed_at'].blank?
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

  private

    def value_by_key(hash, key)
      hash[key.to_s] || hash[key.to_sym]
    end
end
