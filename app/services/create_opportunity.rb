class CreateOpportunity
  def initialize(editor)
    @editor = editor
  end

  def call(params)
    opportunity = Opportunity.new(params)

    if params[:slug].nil?
      opportunity.slug = CreateOpportunitySlug.call(opportunity)
    end

    opportunity.status = :pending
    opportunity.author = @editor
    opportunity.save

    opportunity
  end
end
