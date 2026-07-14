require "rails_helper"

RSpec.describe "API::People", type: :request do
  describe "GET /api/people" do
    let!(:people) { create_list(:person, 2, :with_parents) }

    it "returns every person with basic identity and parent links" do
      get "/api/people"

      expect(response).to have_http_status(:ok)

      payload = response.parsed_body.fetch("people")
      expected_ids = people.flat_map { |person| [ person.id, person.father_id, person.mother_id ] }

      expect(payload.map { |person| person["id"] }).to include(*expected_ids)
      expect(payload.first).to include(
        "id",
        "first_name",
        "last_name",
        "gender",
        "display_name",
        "father",
        "mother"
      )
    end

    it "returns an empty collection when no people exist" do
      Person.update_all(father_id: nil, mother_id: nil)
      Person.delete_all

      get "/api/people"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch("people")).to eq([])
    end
  end

  describe "GET /api/people/:id" do
    let!(:person) { create(:person, :male, :with_parents) }
    let!(:spouse) { create(:person, :female) }
    let!(:child) { create(:person, father: person, mother: spouse) }

    it "returns the person with nested ancestor and descendant trees" do
      get "/api/people/#{person.id}"

      expect(response).to have_http_status(:ok)

      payload = response.parsed_body.fetch("person")
      expect(payload).to include(
        "id" => person.id,
        "first_name" => person.first_name,
        "last_name" => person.last_name,
        "gender" => "male"
      )
      expect(payload["father"]).to include("id" => person.father_id)
      expect(payload["mother"]).to include("id" => person.mother_id)

      expect(payload["ancestors_data"]).to include(
        "id" => person.id,
        "depth" => 0
      )
      expect(payload.dig("ancestors_data", "father", "id")).to eq(person.father_id)

      expect(payload["descendants_data"]).to include(
        "id" => person.id,
        "depth" => 0
      )
      expect(payload.dig("descendants_data", "spouses", 0, "id")).to eq(spouse.id)
      expect(payload.dig("descendants_data", "spouses", 0, "children", 0, "id")).to eq(child.id)
    end

    it "returns not found for an unknown id" do
      get "/api/people/0"

      expect(response).to have_http_status(:not_found)
    end
  end
end
