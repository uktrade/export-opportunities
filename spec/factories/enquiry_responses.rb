FactoryGirl.define do
  factory :enquiry_response do
    editor
    enquiry

    email_body { Faker::Lorem.words(50) }
    attachment { fixture_file_upload('spec/files/tender_sample_file.txt', 'application/text') }
  end
end
