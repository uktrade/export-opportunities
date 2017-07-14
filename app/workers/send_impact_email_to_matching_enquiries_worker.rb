class SendImpactEmailToMatchingEnquiriesWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    pp "impact email automated....3"
    EnquiryFeedbackSurveySender.new.call(Time.zone.now.beginning_of_day-1.day, Time.zone.now.beginning_of_day)
  end
end
