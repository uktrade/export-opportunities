FactoryGirl.define do
  factory :enquiry_response do
    editor
    enquiry

    email_body { Faker::Lorem.words(50) }
  end
end
