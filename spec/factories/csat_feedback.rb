FactoryBot.define do
  factory :csat_feedback, class: CustomerSatisfactionFeedback do 
    url { "www.bob.com" }
    user_journey { "OPPORTUNITY" }
    satisfaction_rating { "SATISFIED" }
    experienced_issues { [] }
    other_detail { "Blah" }
    likelihood_of_return { "EXTREMELY_UNLIKELY" }
    service_improvements_feedback { "Blah" }
  end
end
