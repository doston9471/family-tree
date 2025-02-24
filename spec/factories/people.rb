FactoryBot.define do
  factory :person do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    gender { %w[male female].sample }

    trait :male do
      gender { "male" }
    end

    trait :female do
      gender { "female" }
    end

    trait :with_parents do
      association :father, factory: [ :person, :male ]
      association :mother, factory: [ :person, :female ]
    end
  end
end
