json.person do
  json.id @person.id
  json.first_name @person.first_name
  json.last_name @person.last_name
  json.gender @person.gender
  # json.display_name @person.display_name

  json.father do
    if @person.father
      json.id @person.father.id
      json.first_name @person.father.first_name
      json.last_name @person.father.last_name
      json.display_name @person.father.display_name
    else
      json.null!
    end
  end

  json.mother do
    if @person.mother
      json.id @person.mother.id
      json.first_name @person.mother.first_name
      json.last_name @person.mother.last_name
      json.display_name @person.mother.display_name
    else
      json.null!
    end
  end

  # # String version of trees
  # json.ancestors_tree @person.ancestors_tree
  # json.descendants_tree @person.descendants_tree

  # Structured data version of trees
  json.ancestors_data @person.ancestors_data
  json.descendants_data @person.descendants_data
end
