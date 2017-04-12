FactoryGirl.define do
  factory :opportunity_comment do
    association :opportunity
    association :author, factory: :editor

    message { Faker::Lorem.sentence }
  end
end
