class OppsSensitivityValidator
  def validate_each(opportunity)
    call(opportunity)
  end

  def call(opportunity)
    existing_sensitivity_check = opportunity.opportunity_sensitivity_checks # OpportunitySensitivityCheck.where(opportunity_id: opportunity.id)
    if existing_sensitivity_check.length.positive?
      sensitivity_check = existing_sensitivity_check.last
      { review_recommended: sensitivity_check.review_recommended, category1_score: sensitivity_check.category1_score, category2_score: sensitivity_check.category2_score, category3_score: sensitivity_check.category3_score }
    else
      OpportunitySensitivityRetriever.new.call(opportunity)
    end
  end
end
