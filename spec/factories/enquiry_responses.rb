FactoryGirl.define do
  factory :enquiry_response do
    association :editor
    association :enquiry

    email_body { Faker::Lorem.words(50) }
  end
end
