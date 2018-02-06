class OppsSensitivityValidator
  def validate_each(opportunity) end

  def call(opportunity)
    Rails.logger.info opportunity
    true
  end
end
