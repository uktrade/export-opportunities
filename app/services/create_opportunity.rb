class CreateOpportunity
  include ApplicationHelper

  def initialize(editor, status = :pending, source = :post)
    @editor = editor
    @status = status
    @source = source
  end

  def call(params)
    cpv_ids_arr = []
    # TODO: this works for the spec, but is this what the actual form would submit?
    if params[:cpv_ids].present? && params[:cpv_ids].size <= 1
      cpv_ids_arr << { industry_id: params[:cpv_ids][0], industry_scheme: 'cpv' }
    elsif params[:cpv_ids].present?
      params[:cpv_ids].map { |cpv_id| cpv_ids_arr << { industry_id: cpv_id.to_s, industry_scheme: 'cpv' } }
    end

    cpvs = params[:cpvs] || cpv_ids_arr
    params.delete :cpvs
    params.delete :cpv_ids

    opportunity = Opportunity.new(params)

    if params[:slug].nil?
      opportunity.slug = CreateOpportunitySlug.call(opportunity)
    end

    opportunity.status = @status
    opportunity.author = @editor
    opportunity.source = @source

    begin
      opportunity.save!
      cpvs&.each do |cpv|
        cpv_id = cpv[:industry_id]
        if cpv_id.present?
          cpv = OpportunityCpv.new(
            industry_id: cpv_id.to_s[0..11],
            industry_scheme: cpv[:industry_scheme],
            opportunity_id: opportunity.id
          )
          cpv.save!
          add_sector_from_cpv(opportunity, cpv_id)
        end
      end
    rescue ActiveRecord::RecordNotUnique
      return opportunity
      # TODO: continue importing opps if there is an opp being invalid.
    rescue ActiveRecord::RecordInvalid => e
      raise e if opportunity.source == :post
    end
    opportunity
  end

  private

    # Finds the Sectors corresponding to the cpv code given
    # and adds these to the Opportunity
    def add_sector_from_cpv(opportunity, cpv_id)
      if cpv_id.present?
        sector_ids = CategorisationMicroservice.new(cpv_id).sector_ids
        sector_ids.each do |sector_id|
          if (sector = Sector.find_by(id: sector_id)) &&
             !opportunity.sectors.include?(sector)
            opportunity.sectors << sector
          end
        end
      end
    end
end
