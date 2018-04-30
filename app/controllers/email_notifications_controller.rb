class EmailNotificationsController < ApplicationController
  def show
    user_id = EncryptedParams.decrypt(params[:user_id])
    date = params[:date]
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    @subscription_notifications = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ?', today_date).where(sent: true).where('subscriptions.user_id = ?', user_id)
  end
end
