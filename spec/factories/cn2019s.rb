FactoryBot.define do
  factory :cn2019 do
    order { Faker::Number.number(digits: 7).to_s }
    level { Faker::Number.number(digits: 1).to_s }
    code { Faker::Number.number(digits: 12).to_s }
    description { Faker::Lorem.sentence }
    english_text { Faker::Lorem.sentence }
    parent_description { Faker::Lorem.sentence }
  end
end
