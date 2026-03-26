# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# --- Pedigree A: 4 ancestor levels (great-great-grandparents at depth 4 from the youngest person) ---
def seed_person(first_name:, last_name:, gender:, father: nil, mother: nil)
  attrs = {
    first_name: first_name,
    last_name: last_name,
    gender: gender,
    father_id: father&.id,
    mother_id: mother&.id
  }
  Person.find_by(attrs) || Person.create!(attrs)
end

# Generation 4 (roots)
henry = seed_person(first_name: "Henry", last_name: "Root", gender: "male")
grace = seed_person(first_name: "Grace", last_name: "Root", gender: "female")

# Generation 3
james = seed_person(first_name: "James", last_name: "Alpha", gender: "male", father: henry, mother: grace)
mary = seed_person(first_name: "Mary", last_name: "Alpha", gender: "female")

robert = seed_person(first_name: "Robert", last_name: "Beta", gender: "male")
susan = seed_person(first_name: "Susan", last_name: "Beta", gender: "female")

michael = seed_person(first_name: "Michael", last_name: "Gamma", gender: "male")
nancy = seed_person(first_name: "Nancy", last_name: "Gamma", gender: "female")

# Generation 2
thomas = seed_person(first_name: "Thomas", last_name: "Alpha", gender: "male", father: james, mother: mary)
linda = seed_person(first_name: "Linda", last_name: "Beta", gender: "female", father: robert, mother: susan)
emma = seed_person(first_name: "Emma", last_name: "Gamma", gender: "female", father: michael, mother: nancy)

# Generation 1
david = seed_person(first_name: "David", last_name: "Alpha", gender: "male", father: thomas, mother: linda)

# Generation 0 (youngest — `ancestors_data` reaches depth 4)
seed_person(first_name: "Alex", last_name: "Alpha", gender: "male", father: david, mother: emma)

# --- Pedigree B: 3 ancestor levels (great-grandparents at depth 3) ---
karl = seed_person(first_name: "Karl", last_name: "Berg", gender: "male")
ingrid = seed_person(first_name: "Ingrid", last_name: "Berg", gender: "female")

olaf = seed_person(first_name: "Olaf", last_name: "Berg", gender: "male", father: karl, mother: ingrid)
helga = seed_person(first_name: "Helga", last_name: "Berg", gender: "female")

erik = seed_person(first_name: "Erik", last_name: "Berg", gender: "male", father: olaf, mother: helga)
astrid = seed_person(first_name: "Astrid", last_name: "Berg", gender: "female")

seed_person(first_name: "Saga", last_name: "Berg", gender: "female", father: erik, mother: astrid)
