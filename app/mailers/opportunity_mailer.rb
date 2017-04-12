class OpportunityMailer < ApplicationMailer
  layout 'eig-email'

  def send_opportunity(opportunity, subscription)
    @opportunity = opportunity
    @subscription = SubscriptionPresenter.new(subscription)

    mail to: @subscription.email,
         subject: "New opportunity from #{t('site_name')}: #{@opportunity.title}"
  end
end
