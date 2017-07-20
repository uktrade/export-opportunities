class SendImpactEmailToMatchingEnquiriesWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    EnquiryFeedbackSurveySender.new.call
  end
end
