FactoryGirl.define do
  factory :company_detail do
    name { Faker::Company.name }
    number { Faker::Number.number(8).to_s }
    postcode { Faker::Address.postcode }
  end
end
