class CreateOpportunity
  def initialize(editor, status = :pending)
    @editor = editor
    @status = status
  end

  def call(params)
    opportunity = Opportunity.new(params)

    if params[:slug].nil?
      opportunity.slug = CreateOpportunitySlug.call(opportunity)
    end

    opportunity.status = @status
    opportunity.author = @editor
    opportunity.save

    opportunity
  end
end
