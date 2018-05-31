class SubscriptionsController < ApplicationController
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
    subscriptions = Subscription.where(user_id: current_user.id).where(unsubscribed_at: nil)
    subscription_form = SubscriptionForm.new(subscription_params)

    if subscription_form.valid?
      subscription = CreateSubscription.new.call(subscription_form, current_user)
    else
      redirect_to opportunities_path(s: subscription_form.search_term), alert: subscription_form.errors.full_messages
    end

    @subscription = SubscriptionPresenter.new(subscription)
    render layout: 'layouts/notifications', locals: {
      subscription: @subscription,
      subscriptions: subscriptions,
      content: content,
    }
  end

  def update
    @subscription = Subscription.find(params[:id])
    @subscription.unsubscribe_reason = reason_param

    if @subscription.save
      render status: :accepted
    else
      internal_server_error
    end
  end

  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.unsubscribed_at = DateTime.current

    if @subscription.save
      render status: :accepted
    else
      internal_server_error
    end
  end

  private def require_sso_after_cutoff
    subscription = Subscription.find(params[:id])

    require_sso! if subscription.user.provider == 'exporting_is_great'
  end

  private def reason_param
    reason = params.fetch(:reason)

    reason if Subscription.unsubscribe_reasons.keys.include?(reason)
  end

  private def subscription_params
    params.require(:subscription).permit(query: [:search_term, sectors: [], countries: [], types: [], values: []])
  end
end
