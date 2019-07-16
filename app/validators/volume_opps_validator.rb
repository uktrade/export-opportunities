class VolumeOppsValidator
  def validate_each(opportunity)
    Rails.logger.error("VOLUMEOPS - Validating...")

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

    if !SUPPORTED_LANGUAGES.include?(opportunity[:language].to_s.downcase) ||
      opportunity[:response_due_on].blank? ||
      opportunity[:country_ids].blank? ||
      (opportunity[:buyer_name].blank? && opportunity[:buyer_address].blank?) ||
      opportunity[:contacts_attributes].blank?
      Rails.logger.error("VOLUMEOPS - Validating... failed")
      false
    else
      Rails.logger.error("VOLUMEOPS - Validating... passed")
      true
    end
  end
end
