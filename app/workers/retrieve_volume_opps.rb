class RetrieveVolumeOpps
  include Sidekiq::Worker

  def perform
    editor = Editor.where(email: ENV.fetch('MAILER_FROM_ADDRESS')).first

    today_date = Time.zone.now.strftime('%Y-%m-%d')
    from_date = today_date
    to_date = (Time.zone.now + 1.day).strftime('%Y-%m-%d')

    # fetch opportunities
    VolumeOppsRetriever.new.call(editor, from_date, to_date)

    opportunity_result_set = Opportunity.where('created_at>? and source=1', today_date)

    # run sensitivity checks
    opportunity_result_set.each do |opportunity|
      OpportunitySensitivityRetriever.new.call(opportunity)
    end

    # run quality checks
    opportunity_result_set.each do |opportunity|
      OpportunityQualityRetriever.new.call(opportunity)
    end

    # run rules engine
    opportunity_result_set.each do |opportunity|
      OpportunityRulesEngine.new.call(opportunity)
    end

    # force re-indexing of results
    Opportunity.import query: -> { where('created_at>? and source=1', today_date) }
  end
end
