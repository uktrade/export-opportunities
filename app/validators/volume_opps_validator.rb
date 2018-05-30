class VolumeOppsValidator
  def validate_each(opportunity)
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

    return false if opportunity[:description].blank?
    if opportunity[:title].blank?
      opportunity[:title] = opportunity[:description][0, 80]
    end

    return false if opportunity[:first_published_at].blank?
    return false unless opportunity[:language].to_s.downcase.include? 'en'

    return false if opportunity[:response_due_on].blank?

    return false if opportunity[:country_ids].blank?

    # buyer contact point
    return false if opportunity[:buyer_name].blank? && opportunity[:buyer_address].blank?

    return false if opportunity[:contacts_attributes].blank?

    true
  end
end
