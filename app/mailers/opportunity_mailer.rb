class OpportunityMailer < ApplicationMailer
  layout 'email'

  def send_opportunity(user, opportunities)
    @opportunities = opportunities.first(5)
    @count = opportunities.count
    @user = user
    @view_more_opportunities_user_id = EncryptedParams.encrypt(user.id)
    @date = Time.zone.now.strftime('%Y-%m-%d')

    mail from: "Export Opportunities <#{Figaro.env.MAILER_FROM_ADDRESS!}>",
         to: @user.email,
         subject: "#{@count} matching opportunities"
  end
end
