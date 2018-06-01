class RulesEngine
  SENSITIVITY_SCORE_THRESHOLD = 0.15
  QUALITY_SCORE_THRESHOLD = 56

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

  # check if sensitivity_score is above the business thresholds we have set.
  # returns true if so, false otherwise
  def sensitive_value_threshold?(sensitivity_score)
    weighted_average = (sensitivity_score[:category1_score] * 3 + sensitivity_score[:category2_score] * 2 + sensitivity_score[:category3_score] * 1) / 6
    weighted_average < SENSITIVITY_SCORE_THRESHOLD
  end

  # check if quality_score is above the business thresholds we have set.
  # returns true if so, false otherwise
  def quality_value_threshold?(quality_score)
    quality_score > QUALITY_SCORE_THRESHOLD
  end

  def save_and_publish(opportunity)
    opportunity.status = 2
    opportunity.save!
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
