class CreateOpportunity
  def initialize(editor, status = :pending)
    @editor = editor
    @status = status
  end

  def call(params)
    opportunity_cpvs = params[:opportunity_cpvs]
    params.delete :opportunity_cpvs
    opportunity = Opportunity.new(params)

    if params[:slug].nil?
      opportunity.slug = CreateOpportunitySlug.call(opportunity)
    end

    opportunity.status = @status
    opportunity.author = @editor

    begin
      opportunity.save!
      opportunity_cpvs&.each do |opportunity_cpv|
        opportunity_cpv = OpportunityCpv.new(industry_id: opportunity_cpv[:industry_id], industry_scheme: opportunity_cpv[:industry_scheme], opportunity_id: opportunity.id)
        opportunity_cpv.save!
      end
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.error 'Record not unique >>>>> attempting to insert opportunity:' + params.to_s + ' with ocid:' + opportunity.ocid
    rescue ActiveRecord::RecordInvalid
      Rails.logger.error 'error validating opportunity'
      Rails.logger.error opportunity.inspect
    end
    opportunity
  end
end
