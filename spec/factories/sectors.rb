FactoryBot.define do
  factory :sector do
    slug { Faker::Lorem.words(number: 10).join('-') }
    name { Faker::Superhero.name }
  end
end
