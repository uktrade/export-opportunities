class OppsQualityValidator
  def validate_each(opportunity)
    @title = opportunity.title
    @description = opportunity.description
  end

  def call(opportunity)
    existing_quality_check = opportunity.opportunity_checks # OpportunityCheck.where(opportunity_id: opportunity.id)
    if existing_quality_check.length.positive?
      existing_quality_check.last
    else
      OpportunityQualityRetriever.new.call(opportunity)
    end
  end
end
