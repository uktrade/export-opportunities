FactoryBot.define do
  factory :type do
    sequence(:slug) { |n| [name.downcase.parameterize, n].join('-') }
    name { Faker::Superhero.name }
  end
end
