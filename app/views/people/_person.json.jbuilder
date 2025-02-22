json.extract! person, :id, :first_name, :last_name, :gender, :father_id, :mother_id, :created_at, :updated_at
json.url person_url(person, format: :json)
