FactoryBot.define do
  factory :value do
    sequence(:slug) { |n| [name.downcase.parameterize, n].join('-') }
    name { "#{Faker::Number.number(digits: 3)}k" }
  end
end
