FactoryGirl.define do
  factory :enquiry_response do
    editor
    enquiry

    email_body { Faker::Lorem.words(50) }
    signature { Faker::Lorem.words(10) }
    completed_at { Time.zone.now }
    response_type { [1, 3, 4, 5].sample }
    documents { {} }
  end
end
