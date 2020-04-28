class EmailNotificationsController < ApplicationController

  #
  # On each email notification, users are given a link to this page
  # Accessed via GET
  #
  def destroy
    content = get_content('email_notifications.yml')
    user = User.where(unsubscription_token: params[:unsubscription_token]).first

    unless user
      flash[:error] = "Could not find user"
      redirect_to root_path and return
    end

    user.subscriptions.where(unsubscribed_at: nil).update_all(unsubscribed_at: Time.zone.now)

    OpportunityMailer.unsubscription_confirmation(user.id).deliver_later

    render 'email_notifications/destroy', layout: 'notification', locals: {
      content: content['destroy'],
    }
  end

  #
  # from the "destroy" page, the users can leave a reason why they unsubscribed
  # The form submits to this action
  #
  def update
    content = get_content('email_notifications.yml')
    user = User.where(unsubscription_token: params[:unsubscription_token]).first

    unless user
      flash[:error] = "Could not find user"
      redirect_to root_path and return
    end

    user.subscriptions.update_all(unsubscribe_reason: reason_param)

    render 'email_notifications/update', layout: 'notification', status: :accepted, locals: {
      content: content['update'],
    }
  end

  private

    def reason_param
      reason = params.fetch(:reason)
      reason if Subscription.unsubscribe_reasons.key?(reason)
    end

end
