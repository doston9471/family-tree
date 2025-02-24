require 'rails_helper'

RSpec.describe Person, type: :model do
  describe 'associations' do
    it { should belong_to(:father).class_name('Person').optional }
    it { should belong_to(:mother).class_name('Person').optional }
    it { should have_many(:children_as_father).class_name('Person') }
    it { should have_many(:children_as_mother).class_name('Person') }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it "validates gender inclusion" do
      person = build(:person, gender: 'invalid')
      expect(person).not_to be_valid
      expect(person.errors[:gender]).to include("must be 'male' or 'female'")
    end

    describe 'parent gender validations' do
      let(:male_person) { create(:person, :male) }
      let(:female_person) { create(:person, :female) }

      it 'validates father must be male' do
        person = build(:person, father: female_person)
        expect(person).not_to be_valid
        expect(person.errors[:father]).to include('must be male')
      end

      it 'validates mother must be female' do
        person = build(:person, mother: male_person)
        expect(person).not_to be_valid
        expect(person.errors[:mother]).to include('must be female')
      end
    end
  end

  describe '#display_name' do
    context 'when person has both parents' do
      let(:person) { create(:person, :with_parents) }

      it 'returns full name with parents' do
        expected = "#{person.first_name} #{person.last_name} (child of #{person.father.first_name} and #{person.mother.first_name})"
        expect(person.display_name).to eq(expected)
      end
    end

    context 'when person has no parents' do
      let(:person) { create(:person) }

      it 'returns only full name' do
        expect(person.display_name).to eq("#{person.first_name} #{person.last_name}")
      end
    end
  end

  describe '#ancestors_data' do
    let(:person) { create(:person, :with_parents) }
    let(:data) { person.ancestors_data }

    it 'returns structured data with correct format' do
      expect(data).to include(
        id: person.id,
        name: "#{person.first_name} #{person.last_name}",
        gender: person.gender,
        depth: 0
      )
      expect(data[:father]).to be_present
      expect(data[:mother]).to be_present
    end
  end

  describe '#descendants_data' do
    context 'when person is male' do
      let(:father) { create(:person, :male) }
      let(:mother) { create(:person, :female) }
      let!(:child) { create(:person, father: father, mother: mother) }
      let(:data) { father.descendants_data }

      it 'returns structured data with spouses and children' do
        expect(data).to include(
          id: father.id,
          name: "#{father.first_name} #{father.last_name}",
          gender: 'male'
        )
        expect(data[:spouses]).to be_present
        expect(data[:spouses].first[:children]).to be_present
      end
    end
  end
end
