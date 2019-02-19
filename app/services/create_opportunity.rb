class CreateOpportunity
  include ApplicationHelper

  def initialize(editor, status = :pending, source = :post)
    @editor = editor
    @status = status
    @source = source
  end

  def call(params)
    opportunity_cpvs = params[:opportunity_cpvs] || [{ industry_id: params[:opportunity_cpv_ids], industry_scheme: 'cpv' }]
    params.delete :opportunity_cpvs
    params.delete :opportunity_cpv_ids

    opportunity = Opportunity.new(params)

    if params[:slug].nil?
      opportunity.slug = CreateOpportunitySlug.call(opportunity)
    end

    opportunity.status = @status
    opportunity.author = @editor
    opportunity.source = @source

    begin
      opportunity.save!
      opportunity_cpvs&.each do |opportunity_cpv|
        cpv_id = opportunity_cpv[:industry_id]
        opportunity_cpv = OpportunityCpv.new(
          industry_id: cpv_id,
          industry_scheme: opportunity_cpv[:industry_scheme],
          opportunity_id: opportunity.id
        )
        opportunity_cpv.save!
        add_sector_from_cpv(opportunity, cpv_id)
      end
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.error 'Record not unique >>>>> \
         attempting to insert opportunity:' +
                         params.to_s + ' with ocid:' + opportunity.ocid
      # TODO: continue importing opps if there is an opp being invalid.
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error 'error validating opportunity'
      Rails.logger.error opportunity.inspect
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
