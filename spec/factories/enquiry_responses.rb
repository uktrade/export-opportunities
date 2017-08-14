FactoryGirl.define do
  factory :enquiry_response do
    editor
    enquiry

    email_body { Faker::Lorem.words(50) }
    signature { Faker::Lorem.words(10) }
  end
end
