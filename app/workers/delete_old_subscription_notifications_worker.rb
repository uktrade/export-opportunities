class DeleteOldSubscriptionNotificationsWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    SubscriptionNotification.where('created_at > ?', 30.days.ago).destroy_all
  end
end
