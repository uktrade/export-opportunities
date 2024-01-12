class RetrieveVolumeOpps < ActiveJob::Base
  sidekiq_options retry: 4

  def perform
    editor = Editor.where(email: Figaro.env.MAILER_FROM_ADDRESS!).first

    # we need to fetch from yesterday to tomorrow to be able to get both TED and other sources that get ingested overnight
    now = Time.zone.now
    today_date = now.strftime('%Y-%m-%d')

    # fetch opportunities
    VolumeOppsRetriever.new.call(editor, today_date)

    opportunity_result_set = Opportunity.where(source: :volume_opps, created_at: Time.current.all_day)

    # run sensitivity checks
    opportunity_result_set.each do |opportunity|
      unless opportunity.opportunity_sensitivity_checks.any?
        OpportunitySensitivityRetriever.new.call(opportunity)
      end
    end

    # run rules engine
    opportunity_result_set.each do |opportunity|
      OpportunityRulesEngine.new.call(opportunity)
    end

    # force re-indexing of results
    Opportunity.import query: -> { where(source: :volume_opps, created_at: Time.current.all_day) }
  end
end
