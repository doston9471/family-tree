json.people @people do |person|
  json.id person.id
  json.first_name person.first_name
  json.last_name person.last_name
  json.gender person.gender
  json.display_name person.display_name

  json.father do
    if person.father
      json.id person.father.id
      json.display_name person.father.display_name
    else
      json.null!
    end
  end

  json.mother do
    if person.mother
      json.id person.mother.id
      json.display_name person.mother.display_name
    else
      json.null!
    end
  end
end
