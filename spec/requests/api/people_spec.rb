require 'rails_helper'

RSpec.describe "API::People", type: :request do
  describe "GET /api/people" do
    let!(:people) { create_list(:person, 3, :with_parents) }

    it "returns all people with their basic information" do
      get "/api/people"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json["people"].length).to eq(9) # 3 people + their parents
      expect(json["people"].first).to include(
        "id",
        "first_name",
        "last_name",
        "gender",
        "father",
        "mother"
      )
    end
  end

  describe "GET /api/people/:id" do
    let!(:person) { create(:person, :with_parents) }
    let!(:spouse) { create(:person, gender: person.gender == 'male' ? 'female' : 'male') }
    let!(:child) { create(:person, father: person.gender == 'male' ? person : spouse,
                                  mother: person.gender == 'female' ? person : spouse) }

    it "returns detailed person information with family trees" do
      get "/api/people/#{person.id}"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json["person"]).to include(
        "id",
        "first_name",
        "last_name",
        "gender",
        "ancestors_data",
        "descendants_data"
      )

      expect(json["person"]["ancestors_data"]).to include(
        "id",
        "name",
        "gender",
        "depth"
      )

      expect(json["person"]["descendants_data"]).to include(
        "id",
        "name",
        "gender",
        "depth",
        "spouses"
      )
    end
  end
end
