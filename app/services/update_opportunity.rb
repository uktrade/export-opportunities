class UpdateOpportunity
  def initialize(opportunity)
    @opportunity = opportunity
  end

  def call(params)
    byebug
    opportunity_cpvs = [{ industry_id: params[:opportunity_cpv_ids], industry_scheme: 'cpv' }]
    params.delete :opportunity_cpv_ids

    @opportunity.assign_attributes(params)
    @opportunity.slug = CreateOpportunitySlug.call(@opportunity)
    @opportunity.save

    opportunity_cpvs&.each do |opportunity_cpv|
      cpv_id = opportunity_cpv[:industry_id]
      opportunity_cpv = OpportunityCpv.new(
          industry_id: cpv_id.to_s,
          industry_scheme: opportunity_cpv[:industry_scheme],
          opportunity_id: @opportunity.id
      )
      opportunity_cpv.save!
    end

    @opportunity
  end
end
