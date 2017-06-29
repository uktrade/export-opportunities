FactoryGirl.define do
  factory :service_provider do
    name { Faker::Superhero.name }
    country
  end
end
