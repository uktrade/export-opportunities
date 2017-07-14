class SendImpactEmailToMatchingEnquiriesWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    EnquiryFeedbackSurveySender.new.call(Time.zone.now.beginning_of_day - 1.day, Time.zone.now.beginning_of_day)
  end
end
