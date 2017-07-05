FactoryGirl.define do
  factory :response_document do
    enquiry_response
    email_attachment { fixture_file_upload('spec/tender_sample_file.txt', 'application/text') }
  end
end
