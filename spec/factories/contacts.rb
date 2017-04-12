FactoryGirl.define do
  factory :contact do
    opportunity_id { SecureRandom.uuid }
    name { Faker::Superhero.name }
    email { Faker::Internet.email }
  end
end
