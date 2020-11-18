FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    sequence(:uid)
    sequence(:sso_hashed_uuid)
    sequence(:unsubscription_token)
    provider { 'exporting_is_great' }

    trait :stub do
      uid { nil }
      sso_hashed_uuid { nil }
      provider { nil }
    end
  end
end
