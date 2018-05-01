class EmailNotificationsController < ApplicationController
  def show
    user_id = EncryptedParams.decrypt(params[:user_id])
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    @subscription_notifications = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ?', today_date).where(sent: true).where('subscriptions.user_id = ?', user_id).pluck(&:subscription.id)
  end

  def destroy
    user_id = EncryptedParams.decrypt(params[:user_id])
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    @subscription_ids = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ?', today_date).where(sent: true).where('subscriptions.user_id = ?', user_id).map { |sub_not| sub_not.subscription_id }

    Subscription.where(id: @subscription_ids).update_all(unsubscribed_at: Time.zone.now)
  end
end
