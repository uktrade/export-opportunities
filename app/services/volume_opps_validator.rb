class VolumeOppsValidator
  def valid?(opportunity)
    return false if opportunity[:description].blank?
    return false unless opportunity[:language].to_s.downcase.include? 'en'
    return false if opportunity[:contacts_attributes][0][:name].blank?
    return false if opportunity[:contacts_attributes][0][:email].blank?

    true
  end
end
