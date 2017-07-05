include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :enquiry_response do
    editor
    enquiry

    email_body { Faker::Lorem.words(50) }

    trait :responded do
      response_document
    end
  end
end
