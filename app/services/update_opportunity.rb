class UpdateOpportunity
  def initialize(opportunity)
    @opportunity = opportunity
  end

  def call(params)
    cpv_ids_arr = []
    # TODO: this works for the spec, but is this what the actual form would submit?
    if params[:cpv_ids].present? && params[:cpv_ids].size <= 1
      cpv_ids_arr << { industry_id: params[:cpv_ids][0], industry_scheme: 'cpv' }
    elsif params[:cpv_ids].present?
      params[:cpv_ids].map { |cpv_id| cpv_ids_arr << { industry_id: cpv_id.to_s, industry_scheme: 'cpv' } }
    end

    params.delete :cpv_ids

    @opportunity.assign_attributes(params)
    @opportunity.slug = CreateOpportunitySlug.call(@opportunity)
    @opportunity.save

    # delete existing cpv ids related to the opportunity
    OpportunityCpv.where(opportunity_id: @opportunity.id).delete_all

    # re-add the cpv ids that were passed in the params
    cpv_ids_arr&.each do |cpv|
      cpv_id = cpv[:industry_id]
      cpv = OpportunityCpv.new(
        industry_id: cpv_id.to_s,
        industry_scheme: cpv[:industry_scheme],
        opportunity_id: @opportunity.id
      )
      cpv.save!
    end

    @opportunity
  end
end
