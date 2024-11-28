# frozen_string_literal: true

# CustomerSatisfactionFeedback
class CustomerSatisfactionFeedback < ApplicationRecord
  SATISFACTION_CHOICES = [
    ['VERY_DISSATISFIED', 'Very dissatisfied'],
    ['DISSATISFIED', 'Dissatisfied'],
    ['NEITHER', 'Neither satisfied nor dissatisfied'],
    ['SATISFIED', 'Satisfied'],
    ['VERY_SATISFIED', 'Very satisfied']
  ]
  ISSUES_CHOICES = [
    ['NOT_FIND_LOOKING_FOR', 'I did not find what I was looking for'],
    ['DIFFICULT_TO_NAVIGATE', 'I found it difficult to navigate the service'],
    ['SYSTEM_LACKS_FEATURE', 'The service lacks the feature I need'],
    ['UNABLE_TO_LOAD/REFRESH/ENTER', 'I was unable to load/refresh/enter a page'],
    ['OTHER', 'Other'],
    ['NO_ISSUE', 'I did not experience any issues']
  ]
  LIKELIHOOD_CHOICES =[
    ['EXTREMELY_UNLIKELY', 'Extremely unlikely'],
    ['UNLIKELY', 'Unlikely'],
    ['NEITHER_LIKELY_NOR_UNLIKELY', 'Neither likely nor unlikely'],
    ['LIKELY', 'Likely'],
    ['EXTREMELY_LIKELY', 'Extremely likely'],
    ['DONT_KNOW_OR_PREFER_NOT_TO_SAY', 'Don\'t know/prefer not to say']
  ]
  self.table_name = :csat_feedback
  validates :service_improvements_feedback, length: { maximum: 1200 }
  validate :validate_experienced_issues

  def validate_experienced_issues
    puts 'validating for experienced_issues...'
    if (experienced_issues.include? 'NO_ISSUE') && (experienced_issues.length > 1)
      puts 'in the thing'
      errors.add(:experienced_issues, "can't both experience issues and have no issues")
    end
  end
end
