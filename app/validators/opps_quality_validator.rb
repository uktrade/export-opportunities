class OppsQualityValidator
  def validate_each(opportunity)
    call(opportunity)
  end

  def call(opportunity)
    existing_quality_check = opportunity.opportunity_checks
    if existing_quality_check.length.positive?
      existing_quality_check.last.score
    else
      new_quality_check = OpportunityQualityRetriever.new.call(opportunity)
      if new_quality_check.eql? 'Error'
        0
      else
        new_quality_check.score
      end
    end
  end
end
