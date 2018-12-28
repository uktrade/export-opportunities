FactoryBot.define do
  factory :subscription do
    user

    fake_search_term = Faker::Lorem.word

    search_term { fake_search_term }
    confirmed_at { 1.day.ago }
    confirmation_sent_at { 2.days.ago }
    unsubscribed_at { nil }
    title { fake_search_term }

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :unsubscribed do
      unsubscribed_at { DateTime.yesterday }
    end
  end
end
