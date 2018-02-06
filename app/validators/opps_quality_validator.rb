class OppsQualityValidator
  def validate_each(opportunity)
    @title = opportunity.title
    @description = opportunity.description
  end

  def call(opportunity)
    OpportunityQualityRetriever.new.call(opportunity)
  end
end