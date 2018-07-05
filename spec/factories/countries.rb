FactoryBot.define do
  factory :country do
    slug { Faker::Lorem.words(10).join('-') }
    name { Faker::Address.country }
    published_target { Faker::Number.between(1, 10) }
    responses_target { Faker::Number.between(1, 5) }
    region
  end
end
