FactoryGirl.define do
  factory :enquiry do
    user
    opportunity

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    company_telephone { Faker::PhoneNumber.phone_number }
    company_name { Faker::Company.name }
    company_address { Faker::Address.street_address }
    company_house_number { Faker::Address.building_number.to_s }
    company_postcode { Faker::Address.postcode }
    company_url { Faker::Internet.url }
    existing_exporter { ['Not yet', 'Yes, in the last year', 'Yes, 1-2 years ago', 'Yes, over two years ago'].sample }
    company_sector { Faker::Company.profession }
    company_explanation { Faker::Company.catch_phrase }
  end
end
