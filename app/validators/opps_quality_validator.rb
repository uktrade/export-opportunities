class OppsQualityValidator
  def validate_each(opportunity)
    call(opportunity)
  end

  def call(opportunity)
   existing_quality_check = opportunity.opportunity_checks # OpportunityCheck.where(opportunity_id: opportunity.id)
    if existing_quality_check.length.positive?
      existing_quality_check.last.score
    else
      new_quality_check = OpportunityQualityRetriever.new.call(opportunity)
      new_quality_check.score
    end
  end
end
