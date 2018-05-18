require 'opps_quality_connector'

class OpportunityQualityRetriever
  def call(opportunity)
    hostname = Figaro.env.TG_HOSTNAME!
    quality_api_key = Figaro.env.TG_API_KEY!
    submitted_text = "#{opportunity.title} #{opportunity.description}"[0..1999]

    response = quality_check(hostname, quality_api_key, submitted_text)

    if response[:status]
      opportunity_check = OpportunityCheck.new

      response[:errors]&.each do |opps_quality_error|
        opportunity_check.error_id = opportunity.id
        opportunity_check.offset = opps_quality_error['offset']
        # length of string to be able to mark it as red in text
        opportunity_check.length = opps_quality_error['token'].length
        opportunity_check.offensive_term = opps_quality_error['token']

        # hash with array of values, we pick the first suggestion which has higher probability
        opportunity_check.suggested_term = opps_quality_error['suggestions'][0]['suggestion']

        opportunity_check.submitted_text = submitted_text
        opportunity_check.score = response[:score]
        opportunity_check.opportunity_id = opportunity.id

        opportunity_check.save!
      end

      if response[:errors].length.zero?
        opportunity_check.score = response[:score]
        opportunity_check.opportunity_id = opportunity.id
        opportunity_check.submitted_text = submitted_text

        opportunity_check.save!
      end

      return opportunity_check
    else
      Rails.logger.info 'log errors from API'
      'Error'
      # errors from API
    end
  end

  def quality_check(hostname, quality_api_key, submitted_text)
    OppsQualityConnector.new.call(hostname, quality_api_key, submitted_text)
  end
end
