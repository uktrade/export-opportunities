class OpportunityMailer < ApplicationMailer
  layout 'email'

  def send_opportunity(user, opportunities)
    @count = opportunities.count
    # TODO: don't use sample if the number of opps can be too large
    @opportunities = opportunities.sample(5)
    @user = user
    @encrypted_user_id = EncryptedParams.encrypt(user.id)
    @date = Time.zone.now.strftime('%Y-%m-%d')

    mail from: "Export Opportunities <#{ENV.fetch('MAILER_FROM_ADDRESS')}>",
         to: @user.email,
         subject: "#{@count} matching #{@count > 1 ? 'opportunities' : 'opportunity'}"
  end
end
