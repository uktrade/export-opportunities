FactoryBot.define do
  factory :enquiry_response do
    editor
    enquiry

    email_body { Faker::Lorem.words(number: 50) }
    signature { Faker::Lorem.words(number: 10) }
    completed_at { Time.zone.now }
    response_type { [1, 3, 4, 5].sample }
    documents { {} }

    trait :has_document do
      JSON[
        [
          documents: [
            {
              result: {
                status: 200,
                id: {
                  id: 3,
                  user_id: 1,
                  enquiry_id: 2,
                  original_filename: 'tender_file.pdf',
                  hashed_id: '219d879edd56cd983f90a3e6e3abc541fc4c6e48d2c64af97e563ad89f1bged4',
                  s3_link: 'https://s3/tender_file.pdf',
                  created_at: '2017-09-12T12:46:02.243Z',
                  updated_at: '2017-09-12T12:46:02.243Z',
                },
                base_url: 'https://base_url',
              },
            },
          ],
        ],
      ]
    end
  end
end
