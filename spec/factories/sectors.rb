FactoryGirl.define do
  factory :sector do
    slug { Faker::Lorem.words(10).join('-') }
    name { Faker::Superhero.name }
  end
end
