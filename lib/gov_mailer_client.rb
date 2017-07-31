require 'notifications/client'
require 'notifications/client/response_notification'

class GovMailerClient
  def initialize
    @client = Notifications::Client.new(Figaro.env.GOV_UK_NOTIFY_API_KEY!)
  end

  def send_email(to)
    @client.send_email(
        email_address: to,
        template_id: '7de014d7-8365-40ae-abdb-161787dc796f',
        personalisation: {
            enquiry_response_subject: 'You’ve received an enquiry: Action required within 5 working days',
            enquiry_url: 'https://opportunities.export.great.gov.uk/admin/enquiries/12345',
            opportunity_url: 'https://opportunities.export.great.gov.uk/opportunities/ukraine-hydro-power-station-equipment',
            enquiry_company_house_number: '07821317',
            enquiry_requirements: '"We are brand manufacturers of Wild Cat Energy Drink. \r\nExporting out to several countries.\r\nWe are indeed interested in opening the Indian Market.',
        },
        reference: to + Time.zone.now.to_s
    ) # => Notifications::Client::ResponseNotification
  end
end