FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    sequence(:uid)
    provider 'exporting_is_great'

    trait :stub do
      uid nil
      provider nil
    end
  end
end
