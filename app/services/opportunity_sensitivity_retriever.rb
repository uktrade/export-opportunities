require 'opps_sensitivity_connector'

class OpportunitySensitivityRetriever
  def call(opportunity)
    hostname = Figaro.env.AZ_HOSTNAME!
    sensitivity_api_key = Figaro.env.AZ_API_KEY!
    submitted_text = "#{opportunity.title} #{opportunity.description}"

    response = OppsSensitivityConnector.new.call(submitted_text, hostname, sensitivity_api_key)
    hashed_response = JSON.parse(response)

    if JSON.parse(response)['Status']['Description'].eql? "OK"
      OpportunitySensitivityCheck.new.call()
    else
      Rails.logger.error 'error from API call'
    end
  end
end
