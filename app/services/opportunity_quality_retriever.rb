require 'opps_quality_connector'

class OpportunityQualityRetriever
  def call(opportunity)
    hostname = Figaro.env.TG_HOSTNAME!
    quality_api_key = Figaro.env.TG_API_KEY!
    submitted_text = opportunity.title
    response = OppsQualityConnector.new.call(hostname, quality_api_key, submitted_text)

    if response[:status]

      response[:errors]&.each do |opps_quality_error|
        opportunity_check = OpportunityCheck.new

        opportunity_check.error_id = opps_quality_error['id']
        opportunity_check.offset = opps_quality_error['offset']
        opportunity_check.length = opps_quality_error['length']
        opportunity_check.offensive_term = opps_quality_error['bad']

        # hash with array of values, we pick the first suggestion which has higher probability
        opportunity_check.suggested_term = opps_quality_error['better'].first

        opportunity_check.submitted_text = submitted_text
        opportunity_check.score = response[:score]
        opportunity_check.opportunity_id = opportunity.id

        opportunity_check.save!
      end

      if response[:errors].length.zero?
        opportunity_check = OpportunityCheck.new
        opportunity_check.score = response[:score]
        opportunity_check.opportunity_id = opportunity.id
        opportunity_check.submitted_text = submitted_text

        opportunity_check.save!
      end

      return opportunity_check
    else
      Rails.logger.info 'log errors from API'
      # errors from API
    end
  end
end
