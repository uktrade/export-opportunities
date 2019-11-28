class RulesEngine
  SENSITIVITY_SCORE_THRESHOLD = Figaro.env.SENSITIVITY_SCORE_THRESHOLD.present? ? Figaro.env.SENSITIVITY_SCORE_THRESHOLD.to_i : 0.15
  QUALITY_SCORE_THRESHOLD = Figaro.env.QUALITY_SCORE_THRESHOLD.present? ? Figaro.env.QUALITY_SCORE_THRESHOLD.to_i : 90

  def call(opportunity)
    # Validate sensitivity
    sensitivity_score = OppsSensitivityValidator.new.validate_each(opportunity)

    # if sensitivity pass score is below threshold, validate quality
    if valid_opportunity?(sensitivity_score, opportunity)
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

    def valid_opportunity?(sensitivity_score, opportunity)
      sensitive_value_threshold?(sensitivity_score) && not_about_to_expire(opportunity)
    end

    def not_about_to_expire(opportunity)
      days_warning = Figaro.env.MIN_VOLUME_OPS_DAYS_TO_RESPOND.to_i
      opportunity.response_due_on > days_warning.days.from_now
    end

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
