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

    begin
      opportunity.save!
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.error 'Record not unique >>>>> attempting to insert opportunity:' + params.to_s + ' with ocid:' + opportunity.ocid
    rescue ActiveRecord::RecordInvalid
      Rails.logger.error 'error validating opportunity'
      Rails.logger.error opportunity.inspect
    end
    opportunity
  end
end
