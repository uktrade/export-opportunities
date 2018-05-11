class EmailNotificationsController < ApplicationController
  before_action :require_sso!

  def show
    begin
      user_id = EncryptedParams.decrypt(params[:user_id])
    rescue EncryptedParams::CouldNotDecrypt
      redirect_to not_found && return
    end

    @subscription_notifications = []
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    subscription_notification_ids = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ?', today_date).where(sent: true).where('subscriptions.user_id = ?', user_id).map(&:id)
    subscription_notification_ids.each do |sub_not_id|
      @subscription_notifications.push(SubscriptionNotification.find(sub_not_id))
    end
  end

  def destroy
    user_id = EncryptedParams.decrypt(params[:user_id])
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    @subscription_ids = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ?', today_date).where(sent: true).where('subscriptions.user_id = ?', user_id).map(&:subscription_id)

    Subscription.where(id: @subscription_ids).update_all(unsubscribed_at: Time.zone.now)
  end
end
