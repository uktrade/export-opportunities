class RulesEngine
  def call(opportunity)
    # first validate opp
    valid_opp = VolumeOppsValidator.new.validate_each(opportunity)
byebug
    # if that passes, validate sensitivity
    if valid_opp
      sensitivity_score = OppsSensitivityValidator.new.validate_each(opportunity)
    end
    # if that passes, validate quality

    if sensitive_value_threshold?(sensitivity_score)
      quality_score = OppsQualityValidator.new.validate_each(opportunity)

      if quality_value_threshold?(quality_score)
        # publish opp
        opportunity.status = 4
        opportunity.save!

      # opp is valid, sensitivity value is OK but quality may be below threshold
      else
        resolve_sensitivity_quality_opportunity(sensitivity_score, quality_score)
      end
    else
      resolve_sensitivity_opportunity(sensitivity_score)
    end
  end

  private

  # check if sensitivity_score is above the business thresholds we have set.
  # returns true if so, false otherwise
  def sensitive_value_threshold?(sensitivity_score)
    return true
  end

  # check if quality_score is above the business thresholds we have set.
  # returns true if so, false otherwise
  def quality_value_threshold?(quality_score)
    return true
  end

  def resolve_sensitivity_opportunity(sensitivity_score)
    # based on solely sensitivity score, is it ok to manually review?
  end

  def resolve_sensitivity_quality_opportunity(sensitivity_score, quality_score)
    # based on both scores, decide if we should publish/hold in queue or delete
  end

end