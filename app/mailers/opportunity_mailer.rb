class OpportunityMailer < ApplicationMailer
  layout 'email'

  def send_opportunity(user, struct)
    @count = struct[:count]

    @subscriptions = struct[:subscriptions]
    @user = user

    @date = Time.zone.now.strftime('%Y-%m-%d')

    mail from: "Export Opportunities <#{Figaro.env.MAILER_FROM_ADDRESS!}>",
         to: @user.email,
         subject: "#{@count} matching #{@count > 1 ? 'opportunities' : 'opportunity'}"
  end

  def unsubscription_confirmation(user_id)
    if (@user = User.find_by(id: user_id))
      mail from: "Export Opportunities <#{Figaro.env.MAILER_FROM_ADDRESS!}>",
           to: @user.email,
           subject: 'You have been unsubscribed from all email alerts'
    end
  end
end
