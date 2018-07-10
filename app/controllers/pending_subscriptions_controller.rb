class PendingSubscriptionsController < ApplicationController
  before_action :require_sso!, only: [:update]

  def create
    @pending_subscription = PendingSubscription.create!(query_params: subscription_params)

    redirect_to update_pending_subscription_path(@pending_subscription)
  end

  def update
    content = get_content('pending_subscriptions.yml')

    pending_subscription = PendingSubscription.find(params[:id])
    subscription_form = SubscriptionForm.new(pending_subscription.query_params)

    unless subscription_form.valid?
      return redirect_to opportunities_path(s: subscription_form.search_term), alert: subscription_form.errors.full_messages
    end

    subscription = CreateSubscription.new.call(subscription_form, current_user)
    pending_subscription.update!(subscription: subscription)

    # Suppress the "You are now signed in" message
    flash.clear

    @subscription = SubscriptionPresenter.new(subscription)

    return redirect_to dashboard_path(anchor: 'alerts', target: :alerts)
    # render 'subscriptions/create', locals: { subscriptions: [subscription], subscription: subscription, content: content }
  end

  private def subscription_params
    params.require(:subscription).permit(query: [:search_term, sectors: [], countries: [], types: [], values: []])
  end
end
