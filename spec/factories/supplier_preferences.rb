FactoryBot.define do
  factory :supplier_preference do
    name { Faker::Superhero.name }
    sequence(:slug) { |n| [name.downcase.parameterize, n].join('-') }
  end
end
