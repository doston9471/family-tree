FactoryBot.define do
  factory :person do
    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }
    gender { "male" }

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

    # Person with one child (and that child's other parent as spouse).
    trait :with_child do
      transient do
        child_first_name { "Child" }
      end

      after(:create) do |person, evaluator|
        spouse = if person.gender == "male"
                   create(:person, :female)
        else
                   create(:person, :male)
        end

        create(
          :person,
          first_name: evaluator.child_first_name,
          last_name: person.last_name,
          gender: "male",
          father: person.gender == "male" ? person : spouse,
          mother: person.gender == "female" ? person : spouse
        )
      end
    end

    # Male with children from two different partners (multi-spouse descendants).
    trait :with_multiple_spouses do
      gender { "male" }

      after(:create) do |person|
        first_wife = create(:person, :female)
        second_wife = create(:person, :female)

        create(:person, :male, father: person, mother: first_wife, last_name: person.last_name)
        create(:person, :female, father: person, mother: first_wife, last_name: person.last_name)
        create(:person, :male, father: person, mother: second_wife, last_name: person.last_name)
      end
    end
  end
end
