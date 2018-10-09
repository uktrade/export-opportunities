class OpportunityMailer < ApplicationMailer
  layout 'email'

  def send_opportunity(user, struct)
    @count = struct[:count]
    @subscriptions = struct[:subscriptions]
    @user = user

    @encrypted_user_id = EncryptedParams.encrypt(user.id)
    @date = Time.zone.now.strftime('%Y-%m-%d')

    mail from: "Export Opportunities <#{Figaro.env.MAILER_FROM_ADDRESS!}>",
         to: @user.email,
         subject: "#{@count} matching #{@count > 1 ? 'opportunities' : 'opportunity'}"
  end
end
