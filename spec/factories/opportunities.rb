FactoryBot.define do
  factory :opportunity do
    association :author, factory: :editor
    association :service_provider

    title { Faker::Lorem.sentence[0...Opportunity::TITLE_LENGTH_LIMIT] }
    teaser { Faker::Lorem.sentence[0...Opportunity::TEASER_LENGTH_LIMIT] }

    description { |attrs| attrs[:teaser] + Faker::Lorem.paragraph(sentence_count: 1) }
    sequence(:slug) { |n| [title.downcase.parameterize, n].join('-') }
    source { :post }
    status { :pending }
    first_published_at { Faker::Time.backward(days: 100, period: :morning) }
    response_due_on { Faker::Time.forward(days: 23, period: :morning) }

    trait :published do
      status { :publish }
    end

    trait :drafted do
      status { :draft }
    end

    trait :unpublished do
      status { :pending }
    end

    trait :ragg_red do
      ragg { :red }
    end

    trait :expired do
      response_due_on { Faker::Time.backward(days: 7) }
    end

    after(:build) do |opportunity|
      opportunity.contacts += build_list(:contact, Opportunity::CONTACTS_PER_OPPORTUNITY - opportunity.contacts.length)
    end
  end
end
