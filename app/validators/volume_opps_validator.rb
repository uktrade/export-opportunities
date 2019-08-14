class VolumeOppsValidator
  def validate_each(opportunity)
    Rails.logger.error('VOLUMEOPS - Validating...')

    # title V
    # description V
    # publication date V
    # tender period
    # buyer name V
    # buyer address V
    # country V
    # buyer contact point V

    # also:
    # language

    if opportunity[:title].blank?
      opportunity[:title] = opportunity[:description][0, 80]
    end

    if language_not_supported?(opportunity) ||
       opportunity[:response_due_on].blank? ||
       opportunity[:country_ids].blank? ||
       buyer_blank?(opportunity) ||
       opportunity[:contacts_attributes].blank?
      Rails.logger.error('VOLUMEOPS - Validating... failed')
      false
    else
      Rails.logger.error('VOLUMEOPS - Validating... passed')
      true
    end
  end

  private

    def buyer_blank?(opportunity)
      opportunity[:buyer_name].blank? && opportunity[:buyer_address].blank?
    end

    def language_not_supported?(opportunity)
      !SUPPORTED_LANGUAGES.include?(opportunity[:language].to_s.downcase)
    end
end
