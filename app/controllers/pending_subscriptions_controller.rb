class PendingSubscriptionsController < ApplicationController
  include SubscriptionHelper
  before_action :require_sso!, only: [:update]

  def create
    @pending_subscription = PendingSubscription.create!(query_params: subscription_params)
    render json: nil, status: :created
  end

  def update
    content = get_content('subscriptions.yml')
    @title = content['create']['title']
    pending_subscription = PendingSubscription.find(params[:id])
    create_subscription_from(pending_subscription.query_params, content) do |subscription|
      pending_subscription.update!(subscription: subscription)
      flash.clear # Suppress the "You are now signed in" message
    end
  end
end
