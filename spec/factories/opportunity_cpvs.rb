FactoryBot.define do
  factory :opportunity_cpv do
    association :opportunity

    industry_id { Faker::Number.number(digits: 8) }
    industry_scheme { 'CPV' }
  end
end
