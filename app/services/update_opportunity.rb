class UpdateOpportunity
  def initialize(opportunity)
    @opportunity = opportunity
  end

  def call(params)
    opportunity_cpv_ids_arr = []
    # TODO: this works for the spec, but is this what the actual form would submit?
    if params[:opportunity_cpv_ids].present? && params[:opportunity_cpv_ids].size <= 1
      opportunity_cpv_ids_arr << { industry_id: params[:opportunity_cpv_ids][0], industry_scheme: 'cpv' }
    elsif params[:opportunity_cpv_ids].present?
      params[:opportunity_cpv_ids].map { |cpv_id| opportunity_cpv_ids_arr << { industry_id: cpv_id.to_s, industry_scheme: 'cpv' } }
    end

    params.delete :opportunity_cpv_ids

    @opportunity.assign_attributes(params)
    @opportunity.slug = CreateOpportunitySlug.call(@opportunity)
    @opportunity.save

    opportunity_cpv_ids_arr&.each do |opportunity_cpv|
      cpv_id = opportunity_cpv[:industry_id]
      if OpportunityCpv.where(industry_id: cpv_id).where(opportunity_id: @opportunity.id).length.positive?
        Rails.logger.debug "cpv id #{cpv_id} already exists for opportunity #{@opportunity.id}"
      else
        opportunity_cpv = OpportunityCpv.new(
          industry_id: cpv_id.to_s,
          industry_scheme: opportunity_cpv[:industry_scheme],
          opportunity_id: @opportunity.id
        )
        opportunity_cpv.save!
      end
    end

    @opportunity
  end
end
