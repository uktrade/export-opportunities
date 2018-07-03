FactoryBot.define do
  factory :type do
    slug { Faker::Lorem.words(10).join('-') }
    name { Faker::Superhero.name }
  end
end
