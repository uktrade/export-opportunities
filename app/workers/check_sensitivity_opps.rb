class CheckSensitivityOpps
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    today_date = Time.zone.now.strftime('%Y-%m-%d')
    opportunity_result_set = Opportunity.where('created_at > ?', today_date)
    opportunity_result_set.each do |opportunity|
      OpportunitySensitivityRetriever.new.call(opportunity)
    end
  end
end
