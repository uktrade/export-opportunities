class OpportunityMailer < ApplicationMailer
  layout 'eig-email'

  def send_opportunity(user, opportunities)
    @opportunities = opportunities
    @user = user
    @all_opportunities_link_id = EncryptedParams.encrypt(user.id)
    @date = Time.zone.now.strftime('%Y-%m-%d')

    mail to: @user.email,
         subject: "New opportunities from #{t('site_name')}"
  end
end
