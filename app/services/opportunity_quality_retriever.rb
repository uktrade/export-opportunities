require 'opps_quality_connector'

class OpportunityQualityRetriever
  #
  # Runs an API-driven check on text, and logs the response.
  # If no errors are detected, creates an OpportunityCheck with no errors
  # If errors are detected, creates one OpportunityCheck per error
  # Returns results in an array
  #
  def call(opportunity)
    text_to_test = "#{opportunity.title} #{opportunity.description}"[0..1999]
    check = perform_quality_check(text_to_test)

    if check[:status] != 200
      error_msg = "QualityCheck API failed. API returned status #{check[:status]}"
      Rails.logger.error error_msg
      ['Error']
    else
      log_results(opportunity, check, text_to_test)
    end
  end

  def perform_quality_check(text)
    hostname = Figaro.env.TG_HOSTNAME!
    quality_api_key = Figaro.env.TG_API_KEY!
    OppsQualityConnector.new.call(hostname, quality_api_key, text)
  end

  # Returns array of OpportunityChecks
  def log_results(opportunity, check, text_to_test)
    logged = if check[:errors].blank?
               [OpportunityCheck.create!(opportunity: opportunity,
                                         score: check[:score],
                                         submitted_text: text_to_test)]
             else
               check[:errors]&.map do |error|
                 OpportunityCheck.create!(
                   opportunity: opportunity,
                   error_id: opportunity.id,
                   score: check[:score],
                   submitted_text: text_to_test,
                   offset: error['offset'] - 1,
                   length: error['token'].length,
                   offensive_term: error['token'],
                   suggested_term: error['suggestions'][0]['suggestion']
                 )
               end
             end
    logged
  end
end
