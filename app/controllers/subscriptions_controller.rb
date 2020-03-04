class SubscriptionsController < ApplicationController
  include SubscriptionHelper
  before_action :require_sso!, only: :create
  before_action :require_sso_after_cutoff, only: :destroy

  def show
    subscription = Subscription.find_by(confirmation_token: params[:confirmation_token])
    if subscription.nil? || (!subscription.confirmed? && !subscription.confirm)
      render :error, status: :not_found
    else
      render status: :accepted
    end
  end

  def create
    content = get_content('subscriptions.yml')
    @title = content['create']['title']
    create_subscription_from(subscription_params, content)
  end

  def update
    content = get_content('subscriptions.yml')
    @subscription = Subscription.find(params[:id])
    @subscription.unsubscribe_reason = reason_param
    @title = content['update']['title']

    if @subscription.save
      render layout: 'notification', status: :accepted, locals: {
        content: content['update'],
      }
    else
      internal_server_error
    end
  end

  def destroy
    content = get_content('subscriptions.yml')
    @subscription = Subscription.find(params[:id])
    @subscription.unsubscribed_at = DateTime.current
    @title = content['destroy']['title']

    if @subscription.save
      render layout: 'notification', status: :accepted, locals: {
        subscription: @subscription,
        content: content['destroy'],
      }
    else
      internal_server_error
    end
  end

  private

    def require_sso_after_cutoff
      subscription = Subscription.find(params[:id])

      require_sso! if subscription.user.provider == 'exporting_is_great'
    end

    def reason_param
      reason = params.fetch(:reason)

      reason if Subscription.unsubscribe_reasons.key?(reason)
    end
end
