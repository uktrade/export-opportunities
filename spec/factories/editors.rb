FactoryBot.define do
  factory :editor do
    service_provider
    sequence(:wordpress_id) { |n| (n + 1).to_s }
    email { Faker::Internet.email }
    password { Faker::Internet.password(10, 128) }
    password_confirmation { password }
    name { Faker::Name.name }
    confirmed_at { DateTime.current }
    role 1
    deactivated_at { nil }

    factory :admin do
      role 4
    end

    factory :previewer do
      role 3
    end

    factory :publisher do
      role 2
    end

    factory :uploader do
      role 1
    end

    factory :deactivated do
      deactivated_at { 1.day.ago }
    end
  end
end
