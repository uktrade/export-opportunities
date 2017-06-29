FactoryGirl.define do
  factory :country do
    slug { Faker::Lorem.words(10).join('-') }
    name { Faker::Address.country }
    region
  end
end
