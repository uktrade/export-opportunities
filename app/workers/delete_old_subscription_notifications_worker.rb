class DeleteOldSubscriptionNotificationsWorker < ActiveJob::Base
  sidekiq_options retry: false

  def perform
    SubscriptionNotification.where('created_at < ?', 1.month.ago).destroy_all
  end
end
