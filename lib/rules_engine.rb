class RulesEngine
  SENSITIVITY_SCORE_THRESHOLD = 0.15
  QUALITY_SCORE_THRESHOLD = 96

  def call(opportunity)
    Rails.logger.info("Next check: #{opportunity.id}")
    # Validate sensitivity
    sensitivity_score = OppsSensitivityValidator.new.validate_each(opportunity)

    # if sensitivity pass score is below threshold, validate quality
    if sensitive_value_threshold?(sensitivity_score)
      quality_score = OppsQualityValidator.new.validate_each(opportunity)

      if quality_value_threshold?(quality_score)
        save_and_publish(opportunity)
      else
        # opp is valid, sensitivity value is OK but quality may be below threshold
        save_as_pending(opportunity)
      end
    else
      # opp is valid, sensitivity value is BAD, we don't know about quality
      save_as_trash(opportunity)
    end
  end

  private

  # check if sensitivity_score is below the business thresholds we have set.
  # returns true if so, false otherwise
  def sensitive_value_threshold?(sensitivity_score)
    return false if sensitivity_score[:review_recommended] == true

    weighted_average = (sensitivity_score[:category1_score] * 3 + sensitivity_score[:category2_score] * 2 + sensitivity_score[:category3_score] * 1) / 6
    weighted_average < SENSITIVITY_SCORE_THRESHOLD
  end

  # check if quality_score is above the business thresholds we have set.
  # returns true if so, false otherwise
  def quality_value_threshold?(quality_score)
    quality_score > QUALITY_SCORE_THRESHOLD
  end

  def save_and_publish(opportunity)
    # make sure that we create a subscription notification for matching subscriptions
    result = UpdateOpportunityStatus.new.call(opportunity, 'publish')

    Rails.logger.error("This opportunity has a problem. Please edit and save to resolve any issues: #{opportunity.id}") unless result.success?
  end

  def save_as_pending(opportunity)
    opportunity.status = 1
    opportunity.save!
  end

  def save_as_trash(opportunity)
    opportunity.status = 4
    opportunity.save!
  end
end
