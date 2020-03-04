FactoryBot.define do
  factory :country do
    slug { Faker::Lorem.words(number: 10).join('-') }
    name { Faker::Address.country }
    published_target { Faker::Number.between(from: 1, to: 10) }
    responses_target { Faker::Number.between(from: 1, to: 5) }
    region { Region.create(name: "Eurasia") }
  end
end
