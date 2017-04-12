class BulkSubscriptionsController < ApplicationController
  before_action :require_sso!, only: [:create]

  def index
    @subscription = Subscription.new

    # Suppress the "You are now signed in" message
    flash.clear
  end

  def create
    subscription = current_user.subscriptions.create!(confirmed_at: Time.zone.now)

    @subscription = SubscriptionPresenter.new(subscription)
    render locals: { subscription: @subscription }
  end
end
