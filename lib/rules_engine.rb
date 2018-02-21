class RulesEngine
  SENSITIVITY_SCORE_THRESHOLD = 0
  QUALITY_SCORE_THRESHOLD = 56

  def call(opportunity)
    # first validate opp
    valid_opp = VolumeOppsValidator.new.validate_each(opportunity)

    # if that passes, validate sensitivity
    if valid_opp
      sensitivity_score = OppsSensitivityValidator.new.validate_each(opportunity)
    end

    # if sensitivity pass is above threshold, validate quality
    if sensitive_value_threshold?(sensitivity_score)
      quality_score = OppsQualityValidator.new.validate_each(opportunity)

      if quality_value_threshold?(quality_score)
        # publish opp
        opportunity.status = 4
        opportunity.save!

      # opp is valid, sensitivity value is OK but quality may be below threshold
      else
        save_as_pending(opportunity)
      end
    # opp is valid, sensitivity value is BAD, we don't know about quality
    else
      save_as_pending(opportunity)
    end
  end

  private

  # check if sensitivity_score is above the business thresholds we have set.
  # returns true if so, false otherwise
  def sensitive_value_threshold?(sensitivity_score)
    sensitivity_score > SENSITIVITY_SCORE_THRESHOLD
  end

  # check if quality_score is above the business thresholds we have set.
  # returns true if so, false otherwise
  def quality_value_threshold?(quality_score)
    quality_score > QUALITY_SCORE_THRESHOLD
  end

  def save_as_pending(opportunity)
    opportunity.status = 2
    opportunity.save!
  end
end
