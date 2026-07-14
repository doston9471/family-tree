require "rails_helper"

RSpec.describe "People", type: :request do
  describe "GET /people" do
    it "lists people and the branded home content" do
      person = create(:person, first_name: "Nora", last_name: "Index")

      get people_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ancestry Tree")
      expect(response.body).to include("Nora Index")
      expect(response.body).to include(person_path(person))
    end

    it "shows an empty state when there are no people" do
      Person.update_all(father_id: nil, mother_id: nil)
      Person.delete_all

      get people_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Your tree is empty")
    end
  end

  describe "GET /people/:id" do
    it "renders ancestor and descendant sections" do
      person = create(:person, :male, :with_parents, first_name: "Oliver", last_name: "Show")
      spouse = create(:person, :female, first_name: "Priya", last_name: "Show")
      create(:person, father: person, mother: spouse, first_name: "Nora", last_name: "Show")

      get person_path(person)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Oliver Show")
      expect(response.body).to include("Ancestors")
      expect(response.body).to include("Descendants")
      expect(response.body).to include(person.father.first_name)
      expect(response.body).to include("Priya Show")
      expect(response.body).to include("Nora Show")
    end
  end

  describe "GET /people/new" do
    it "renders the new person form" do
      get new_person_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("New person")
    end
  end

  describe "POST /people" do
    let!(:father) { create(:person, :male) }
    let!(:mother) { create(:person, :female) }

    it "creates a person and redirects to the show page" do
      expect {
        post people_path, params: {
          person: {
            first_name: "Saga",
            last_name: "Create",
            gender: "female",
            father_id: father.id,
            mother_id: mother.id
          }
        }
      }.to change(Person, :count).by(1)

      person = Person.order(:id).last
      expect(response).to redirect_to(person)
      expect(flash[:notice]).to eq("Person was successfully created.")
      follow_redirect!
      expect(response.body).to include("Saga Create")
    end

    it "re-renders the form when invalid" do
      expect {
        post people_path, params: {
          person: {
            first_name: "",
            last_name: "Create",
            gender: "female"
          }
        }
      }.not_to change(Person, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("New person")
    end
  end

  describe "GET /people/:id/edit" do
    it "renders the edit form" do
      person = create(:person, first_name: "Erik", last_name: "Edit")

      get edit_person_path(person)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Erik Edit")
    end
  end

  describe "PATCH /people/:id" do
    let!(:person) { create(:person, first_name: "Erik", last_name: "Update") }

    it "updates the person and redirects" do
      patch person_path(person), params: {
        person: { first_name: "Bjorn", last_name: "Update", gender: person.gender }
      }

      expect(response).to redirect_to(person)
      expect(person.reload.first_name).to eq("Bjorn")
      expect(flash[:notice]).to eq("Person was successfully updated.")
    end

    it "re-renders the form when invalid" do
      patch person_path(person), params: {
        person: { first_name: "", last_name: "Update", gender: person.gender }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(person.reload.first_name).to eq("Erik")
    end
  end

  describe "DELETE /people/:id" do
    it "destroys the person and redirects to the index" do
      person = create(:person)

      expect {
        delete person_path(person)
      }.to change(Person, :count).by(-1)

      expect(response).to redirect_to(people_path)
      expect(flash[:notice]).to eq("Person was successfully destroyed.")
    end
  end
end
