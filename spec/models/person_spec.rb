require "rails_helper"

RSpec.describe Person, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:father).class_name("Person").optional }
    it { is_expected.to belong_to(:mother).class_name("Person").optional }
    it { is_expected.to have_many(:children_as_father).class_name("Person") }
    it { is_expected.to have_many(:children_as_mother).class_name("Person") }
  end

  describe "validations" do
    subject { build(:person) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_inclusion_of(:gender).in_array(%w[male female]).with_message("must be 'male' or 'female'") }

    it "rejects a duplicate first/last name with the same parents" do
      existing = create(:person, :with_parents, first_name: "Alex", last_name: "Stone")
      duplicate = build(
        :person,
        first_name: "Alex",
        last_name: "Stone",
        gender: existing.gender,
        father: existing.father,
        mother: existing.mother
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:first_name]).to include("already exists with the same parents")
    end

    it "allows the same name when parents differ" do
      first = create(:person, :with_parents, first_name: "Alex", last_name: "Stone")
      other = build(
        :person,
        first_name: "Alex",
        last_name: "Stone",
        gender: first.gender,
        father: create(:person, :male),
        mother: create(:person, :female)
      )

      expect(other).to be_valid
    end

    describe "parent gender validations" do
      let(:male) { create(:person, :male) }
      let(:female) { create(:person, :female) }

      it "requires father to be male" do
        person = build(:person, father: female)

        expect(person).not_to be_valid
        expect(person.errors[:father]).to include("must be male")
      end

      it "requires mother to be female" do
        person = build(:person, mother: male)

        expect(person).not_to be_valid
        expect(person.errors[:mother]).to include("must be female")
      end
    end
  end

  describe "#display_name" do
    it "includes both parents when present" do
      person = create(:person, :with_parents, first_name: "Nora", last_name: "Vale")

      expect(person.display_name).to eq(
        "Nora Vale (child of #{person.father.first_name} and #{person.mother.first_name})"
      )
    end

    it "returns only the full name without parents" do
      person = create(:person, first_name: "Edmund", last_name: "Willow")

      expect(person.display_name).to eq("Edmund Willow")
    end

    it "returns only the full name when a single parent is present" do
      mother = create(:person, :female, first_name: "Julia")
      person = create(:person, first_name: "Clara", last_name: "Moss", mother: mother)

      expect(person.display_name).to eq("Clara Moss")
    end
  end

  describe "#children" do
    it "returns children linked as father when male" do
      father = create(:person, :male)
      mother = create(:person, :female)
      child = create(:person, father: father, mother: mother)

      expect(father.children).to contain_exactly(child)
    end

    it "returns children linked as mother when female" do
      father = create(:person, :male)
      mother = create(:person, :female)
      child = create(:person, father: father, mother: mother)

      expect(mother.children).to contain_exactly(child)
    end
  end

  describe "#ancestors_data" do
    it "returns the person at depth 0 with nested parents" do
      person = create(:person, :with_parents)
      data = person.ancestors_data

      expect(data).to include(
        id: person.id,
        name: "#{person.first_name} #{person.last_name}",
        gender: person.gender,
        depth: 0
      )
      expect(data[:father]).to include(id: person.father_id, depth: 1, gender: "male")
      expect(data[:mother]).to include(id: person.mother_id, depth: 1, gender: "female")
    end

    it "nests grandparents at increasing depth" do
      grandfather = create(:person, :male, first_name: "Edmund")
      grandmother = create(:person, :female, first_name: "Hannah")
      father = create(:person, :male, father: grandfather, mother: grandmother)
      mother = create(:person, :female)
      person = create(:person, father: father, mother: mother)

      data = person.ancestors_data

      expect(data.dig(:father, :father)).to include(id: grandfather.id, depth: 2, name: "Edmund #{grandfather.last_name}")
      expect(data.dig(:father, :mother)).to include(id: grandmother.id, depth: 2)
      expect(data[:mother]).not_to have_key(:father)
      expect(data[:mother]).not_to have_key(:mother)
    end

    it "omits missing parents" do
      mother = create(:person, :female)
      person = create(:person, mother: mother)

      data = person.ancestors_data

      expect(data).not_to have_key(:father)
      expect(data[:mother]).to include(id: mother.id)
    end
  end

  describe "#descendants_data" do
    it "groups a male person's children under each spouse" do
      father = create(:person, :with_multiple_spouses)
      data = father.descendants_data

      expect(data).to include(id: father.id, gender: "male", depth: 0)
      expect(data[:spouses].size).to eq(2)
      expect(data[:spouses].map { |s| s[:children].size }).to contain_exactly(2, 1)
      expect(data[:spouses].flat_map { |s| s[:children] }.map { |c| c[:depth] }).to all(eq(1))
    end

    it "groups a female person's children under each spouse" do
      mother = create(:person, :female, :with_child)
      data = mother.descendants_data

      expect(data[:spouses].size).to eq(1)
      expect(data[:spouses].first).to include(gender: "male")
      expect(data[:spouses].first[:children].first).to include(
        name: "Child #{mother.last_name}",
        depth: 1
      )
    end

    it "returns an empty spouses list when there are no children" do
      person = create(:person)

      expect(person.descendants_data[:spouses]).to eq([])
    end

    it "nests grandchildren under children" do
      father = create(:person, :male)
      mother = create(:person, :female)
      child = create(:person, :male, father: father, mother: mother)
      child_spouse = create(:person, :female)
      grandchild = create(:person, father: child, mother: child_spouse, first_name: "Sam")

      data = father.descendants_data
      nested_child = data[:spouses].first[:children].first

      expect(nested_child[:spouses].first[:children].first).to include(
        id: grandchild.id,
        name: "Sam #{grandchild.last_name}",
        depth: 2
      )
    end
  end

  describe "#ancestors_tree" do
    it "includes the person and labeled parents" do
      person = create(:person, :with_parents, first_name: "Nora", last_name: "Vale")
      tree = person.ancestors_tree

      expect(tree).to include("Nora Vale")
      expect(tree).to include("Father:")
      expect(tree).to include("Mother:")
      expect(tree).to include(person.father.first_name)
      expect(tree).to include(person.mother.first_name)
    end
  end

  describe "#descendants_tree" do
    it "includes spouse and child labels for a male person" do
      father = create(:person, :male, first_name: "Victor")
      mother = create(:person, :female, first_name: "Elena")
      create(:person, father: father, mother: mother, first_name: "Daniel")

      tree = father.descendants_tree

      expect(tree).to include("Victor")
      expect(tree).to include("Wife:")
      expect(tree).to include("Elena")
      expect(tree).to include("Daniel")
    end

    it "includes spouse and child labels for a female person" do
      mother = create(:person, :female, first_name: "Elena")
      father = create(:person, :male, first_name: "Victor")
      create(:person, father: father, mother: mother, first_name: "Daniel")

      tree = mother.descendants_tree

      expect(tree).to include("Elena")
      expect(tree).to include("Husband:")
      expect(tree).to include("Victor")
      expect(tree).to include("Daniel")
    end
  end
end
