FactoryGirl.define do
  factory :region do
    name { Faker::Address.country }
  end
end
