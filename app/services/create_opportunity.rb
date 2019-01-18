class CreateOpportunity
  include ApplicationHelper

  def initialize(editor, status = :pending, source = :post)
    @editor = editor
    @status = status
    @source = source
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
    opportunity.source = @source

    begin
      opportunity.save!
      opportunity_cpvs&.each do |opportunity_cpv|
        opportunity_cpv = OpportunityCpv.new(industry_id: opportunity_cpv[:industry_id], industry_scheme: opportunity_cpv[:industry_scheme], opportunity_id: opportunity.id)
        opportunity_cpv.save!
      end
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.error 'Record not unique >>>>> attempting to insert opportunity:' + params.to_s + ' with ocid:' + opportunity.ocid
      # TODO: continue importing opps if there is an opp being invalid.
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error 'error validating opportunity'
      Rails.logger.error opportunity.inspect
      raise e if opportunity.source == :post
    end
    opportunity
  end
end
