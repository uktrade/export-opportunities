class DeleteOldSubscriptionNotificationsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    SubscriptionNotification.where('created_at < ?', 1.month.ago).delete_all
  end
end
