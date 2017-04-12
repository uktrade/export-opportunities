FactoryGirl.define do
  factory :opportunity do
    association :author, factory: :editor
    association :service_provider

    title { Faker::Lorem.sentence[0...Opportunity::TITLE_LENGTH_LIMIT] }
    teaser { Faker::Lorem.sentence[0...Opportunity::TEASER_LENGTH_LIMIT] }

    description { |attrs| attrs[:teaser] + Faker::Lorem.paragraph(1) }
    sequence(:slug) { |n| [title.downcase.parameterize, n].join('-') }
    status { :pending }
    response_due_on { Faker::Time.forward(23, :morning) }

    trait :published do
      status { :publish }
    end

    trait :unpublished do
      status { :pending }
    end

    trait :expired do
      response_due_on { Faker::Time.backward(7) }
    end

    after(:build) do |opportunity|
      opportunity.contacts += build_list(:contact, Opportunity::CONTACTS_PER_OPPORTUNITY - opportunity.contacts.length)
    end
  end
end
