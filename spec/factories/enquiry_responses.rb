FactoryGirl.define do
  factory :enquiry_response do
    editor
    enquiry

    email_body { Faker::Lorem.words(50) }
    signature { Faker::Lorem.words(10) }
    completed_at { DateTime.now }
    response_type { Faker::Number.between(1, 5) }
  end
end
