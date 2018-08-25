require 'opps_sensitivity_connector'

class OpportunitySensitivityRetriever
  def call(opportunity)
    hostname = ENV.fetch('AZ_HOSTNAME')
    sensitivity_api_key = ENV.fetch('AZ_API_KEY')
    submitted_text = "#{opportunity.title} #{opportunity.description}"[0..1023]

    response = OppsSensitivityConnector.new.call(submitted_text, hostname, sensitivity_api_key)
    hashed_response = JSON.parse(response)

    valid_response = validate_response(hashed_response)

    if valid_response
      opp_sensitivity_check = OpportunitySensitivityCheck.new

      opp_sensitivity_check.error_id = hashed_response['TrackingId']
      opp_sensitivity_check.submitted_text = hashed_response['OriginalText']

      classification = hashed_response['Classification']
      opp_sensitivity_check.review_recommended = false
      opp_sensitivity_check.category1_score = classification['Category1']['Score']
      opp_sensitivity_check.category2_score = classification['Category2']['Score']
      opp_sensitivity_check.category3_score = classification['Category3']['Score']

      opp_sensitivity_check.language = hashed_response['Language']

      opp_sensitivity_check.opportunity_id = opportunity.id

      opp_sensitivity_check.save!

      hashed_response['Terms']&.each do |term|
        check_term = OpportunitySensitivityTermCheck.new
        check_term.index = term['Index']
        check_term.original_index = term['OriginalIndex']
        check_term.list_id = term['ListId']
        check_term.term = term['Term']

        check_term.opportunity_sensitivity_check_id = opp_sensitivity_check.id

        check_term.save!

        opp_sensitivity_check.review_recommended = true

        opp_sensitivity_check.save!
      end

      { review_recommended: opp_sensitivity_check.review_recommended, category1_score: opp_sensitivity_check.category1_score, category2_score: opp_sensitivity_check.category2_score, category3_score: opp_sensitivity_check.category3_score }
    else
      Rails.logger.error "unknown error from API call #{hashed_response}"
    end
  end

  def personal_identifiable_information(submitted_text)
    hostname = ENV.fetch('AZ_HOSTNAME')
    sensitivity_api_key = ENV.fetch('AZ_API_KEY')

    response = OppsSensitivityConnector.new.call(submitted_text, hostname, sensitivity_api_key)

    hashed_response = JSON.parse(response)
    valid_response = validate_response(hashed_response)

    if valid_response
      pii_information = hashed_response['PII']
      return false if pii_information.empty?

      email = pii_information['Email']
      address = pii_information['Address']
      phone = pii_information['Phone']

      return false if email.empty? && address.empty? && phone.empty?

      response = {}

      response[:email] = email[0]['Detected'] if email[0]
      response[:address] = address[0]['Text'] if address[0]
      response[:phone] = { country_code: phone[0]['CountryCode'], number: phone[0]['Text'] } if phone[0]

      return response
    end
  end

  private def validate_response(hashed_response)
    if hashed_response['Message'].eql? 'Error'
      Rails.logger.error hashed_response['Errors']
      return false
    end

    # if we are rate limited by the API, we will discard the current sensitivity check in this run and go to the next one
    if hashed_response['statusCode'].eql? 429
      sleep 0.2
      return false
    end
    if hashed_response.present? && hashed_response['Status'].present? && hashed_response['Status']['Description'] == 'OK'
      true
    else
      false
    end
  end
end
