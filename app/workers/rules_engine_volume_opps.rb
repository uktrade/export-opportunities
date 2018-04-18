class RulesEngineVolumeOpps
  include Sidekiq::Worker

  def perform
    today_date = Time.zone.now.strftime('%Y-%m-%d')
    opportunity_result_set = Opportunity.where('created_at > ?', today_date)
    opportunity_result_set.each do |opportunity|
      OpportunityRulesEngine.new.call(opportunity)
    end
    Opportunity.import
  end
end
