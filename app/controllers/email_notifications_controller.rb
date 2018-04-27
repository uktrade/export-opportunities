class EmailNotificationsController < ApplicationController

  def show
    user_id = EncryptedParams.decrypt(params[:user_id])
    date = params[:date]
    from_date = Date.parse(date)
    to_date = Date.parse(date) + 1.day

    @subscription_notifications = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ? and subscription_notifications.created_at < ?', from_date, to_date).where(sent: true).where('subscriptions.user_id = ?', '62740d0b-d5b3-40c7-aeb6-4be50d6c402e').first
  end
end
