FactoryBot.define do
  super_name = Faker::Superhero.name
  factory :supplier_preference do
    name { super_name }
    slug { super_name.parameterize }

  end
end
