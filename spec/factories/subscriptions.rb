FactoryGirl.define do
  factory :subscription do
    user

    search_term { Faker::Lorem.word }
    confirmed_at { 1.day.ago }
    confirmation_sent_at { 2.days.ago }
    unsubscribed_at nil

    trait :unconfirmed do
      confirmed_at nil
    end

    trait :unsubscribed do
      unsubscribed_at { DateTime.yesterday }
    end
  end
end
