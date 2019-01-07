FactoryBot.define do
  factory :subscription_notification do
    subscription
    opportunity

    created_at { 1.minute.ago }
    updated_at { 1.minute.ago }
    sent { false }

    trait :sent do
      sent { true }
    end
  end
end
