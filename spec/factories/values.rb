FactoryGirl.define do
  factory :value do
    slug { Faker::Number.number(7) }
    name { "#{Faker::Number.number(3)}k" }
  end
end
