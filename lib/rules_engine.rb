class RulesEngine
  SENSITIVITY_SCORE_THRESHOLD = Figaro.env.SENSITIVITY_SCORE_THRESHOLD.present? ? Figaro.env.SENSITIVITY_SCORE_THRESHOLD.to_i : 0.15
  QUALITY_SCORE_THRESHOLD = Figaro.env.QUALITY_SCORE_THRESHOLD.present? ? Figaro.env.QUALITY_SCORE_THRESHOLD.to_i : 90

  def call(opportunity)
    Rails.logger.error("VOLUMEOPS - Rules engine...")
    Rails.logger.info("Next check: #{opportunity.id}")
    # Validate sensitivity
    sensitivity_score = OppsSensitivityValidator.new.validate_each(opportunity)

    # if sensitivity pass score is below threshold, validate quality
    Rails.logger.error("VOLUMEOPS - Rules - Checking sensitivity threshold...")
    if sensitive_value_threshold?(sensitivity_score)
      Rails.logger.error("VOLUMEOPS - Rules - Checking sensitivity threshold... done")
      quality_score = OppsQualityValidator.new.validate_each(opportunity)

      Rails.logger.error("VOLUMEOPS - Rules - Checking quality threshold...")
      if quality_value_threshold?(quality_score)
        Rails.logger.error("VOLUMEOPS - Rules - Checking quality threshold... done")
        Rails.logger.error("VOLUMEOPS - Rules - Publishing...")
        save_and_publish(opportunity)
        Rails.logger.error("VOLUMEOPS - Rules - Publishing... done")
      else
        # opp is valid, sensitivity value is OK but quality may be below threshold
        Rails.logger.error("VOLUMEOPS - Rules - Saving as pending...")
        save_as_pending(opportunity)
        Rails.logger.error("VOLUMEOPS - Rules - Saving as pending... done")
      end
    else
      Rails.logger.error("VOLUMEOPS - Rules - Checking sensitivity threshold... failed")
      # opp is valid, sensitivity value is BAD, we don't know about quality
      Rails.logger.error("VOLUMEOPS - Rules - Saving as trash...")
      save_as_trash(opportunity)
      Rails.logger.error("VOLUMEOPS - Rules - Saving as trash... done")
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
