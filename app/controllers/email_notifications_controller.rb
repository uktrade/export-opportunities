class EmailNotificationsController < ApplicationController
  before_action :require_sso!

  def show
    content = get_content('email_notifications.yml')
    begin
      user_id = EncryptedParams.decrypt(params[:user_id])
    rescue EncryptedParams::CouldNotDecrypt
      redirect_to not_found && return
    end

    result_set = Set.new

    subscriptions = Subscription.where(user_id: user_id)

    if every_opportunity_subscription?(subscriptions)
      query = Opportunity.public_search(
          search_term: nil,
          filters: SearchFilter.new,
          sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
      )
      @results = query.records.to_a
      @paginatable_results = Kaminari.paginate_array(@results).page(params[:page]).per(10)
    else
      subscriptions.each do |subscription|
        params = {
            sectors: subscription.sectors,
            countries: subscription.countries,
            types: subscription.types,
            values: subscription.values,
        }
        query = Opportunity.public_search(
            search_term: subscription.search_term,
            filters: SearchFilter.new(params),
            sort: OpportunitySort.new(default_column: 'updated_at', default_order: 'desc')
        )
        query.records.to_a.each do |opp|
          result_set.add(opp)
        end
      end

      @results = result_set.to_a
      @paginatable_results = Kaminari.paginate_array(@results).page(params[:page]).per(10)
    end


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

  private def every_opportunity_subscription?(subscriptions)
    subscriptions.each do |subscription|
      if subscription.search_term='' && subscription.countries.size == 0 && subscription.types.size == 0 && subscription.values.size == 0 && subscription.sectors.size == 0
        return true
      end
    end
    return false
  end
end
