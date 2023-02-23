class SendImpactEmailToMatchingEnquiriesWorker < ActiveJob::Base
  sidekiq_options retry: false

  def perform
    EnquiryFeedbackSurveySender.new.call
  end
end
