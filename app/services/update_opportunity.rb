class UpdateOpportunity
  def initialize(opportunity)
    @opportunity = opportunity
  end

  def call(params)
    @opportunity.assign_attributes(params)
    @opportunity.slug = CreateOpportunitySlug.call(@opportunity)
    @opportunity.save

    @opportunity
  end
end
