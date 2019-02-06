class OppsQualityValidator
  #
  # For a given opportunity,
  # returns the quality score for either the first available quality check or
  # the score from a fresh quality check
  #
  def validate_each(opportunity)
    call(opportunity)
  end

  def call(opportunity)
    if opportunity.opportunity_checks.any?
      opportunity.opportunity_checks.last.score
    else
      perform_checks(opportunity)
    end
  end

  private

    def perform_checks(opportunity)
      checks = OpportunityQualityRetriever.new.call(opportunity)
      if checks.include? 'Error'
        0
      else
        checks.first.score
      end
    end
end
