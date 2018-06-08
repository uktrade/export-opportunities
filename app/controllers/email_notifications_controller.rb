class EmailNotificationsController < ApplicationController
  before_action :require_sso!

  def show
    content = get_content('email_notifications.yml')
    begin
      user_id = EncryptedParams.decrypt(params[:user_id])
    rescue EncryptedParams::CouldNotDecrypt
      redirect_to not_found && return
    end

    @subscription_notifications = []
    @results = []
    today_date = Time.zone.now.strftime('%Y-%m-%d')

    subscription_notification_ids = SubscriptionNotification.joins(:subscription).where('subscription_notifications.created_at >= ?', today_date).where(sent: true).where('subscriptions.user_id = ?', user_id).map(&:id)
    subscription_notification_ids.each do |sub_not_id|
      @results.push(SubscriptionNotification.find(sub_not_id).opportunity)
      break if @results.size >= 1000
    end
    @paginatable_results = Kaminari.paginate_array(@results).page(params[:page]).per(10)

    render layout: 'results', locals: {
      content: content['show'],
    }
  end

  def destroy
    content = get_content('email_notifications.yml')
    user_id = EncryptedParams.decrypt(params[:user_id])

    @subscription_ids = SubscriptionNotification.joins(:subscription).where(sent: true).where('subscriptions.user_id = ?', user_id).map(&:subscription_id)

    Subscription.where(id: @subscription_ids).update_all(unsubscribed_at: Time.zone.now)
    render 'email_notifications/destroy', layout: 'notification', locals: {
      content: content['destroy'],
    }
  end

  def update
    content = get_content('email_notifications.yml')
    user_id = EncryptedParams.decrypt(params[:id])
    @subscription_ids = SubscriptionNotification.joins(:subscription).where(sent: true).where('subscriptions.user_id = ?', user_id).map(&:subscription_id)

    Subscription.where(id: @subscription_ids).update_all(unsubscribe_reason: reason_param)

    render 'email_notifications/update', layout: 'notification', status: :accepted, locals: {
      content: content['update'],
    }
  end

  private def reason_param
    reason = params.fetch(:reason)
    reason if Subscription.unsubscribe_reasons.keys.include?(reason)
  end
end
