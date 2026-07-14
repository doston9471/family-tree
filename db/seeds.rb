# Idempotent local seed data for exercising ancestor/descendant UIs.
# Reload with: bin/rails db:seed
#
# Useful people to open after seeding:
#   Deep ancestors ........ Nora Vale
#   Wide descendants ...... Edmund Willow
#   Multiple wives ........ Victor Cross  (3 wives, uneven kids per wife)
#   No ancestors .......... Edmund Willow
#   No descendants ........ Nora Vale / Finn Berg
#   Partial parents ....... Clara Moss (mother only)

puts "Seeding people..."

# Reset so re-seeding always yields the same tree shape locally.
Person.update_all(father_id: nil, mother_id: nil)
Person.delete_all

def person!(first_name:, last_name:, gender:, father: nil, mother: nil)
  Person.create!(
    first_name: first_name,
    last_name: last_name,
    gender: gender,
    father: father,
    mother: mother
  )
end

# =============================================================================
# Pedigree A — Willow / Vale
# Deep ancestors (5 generations up from Nora) + branching descendants from Edmund
# =============================================================================

# Gen 4 (roots)
edmund  = person!(first_name: "Edmund",  last_name: "Willow", gender: "male")
hannah  = person!(first_name: "Hannah",  last_name: "Willow", gender: "female")
arthur  = person!(first_name: "Arthur",  last_name: "Ash",    gender: "male")
bridget = person!(first_name: "Bridget", last_name: "Ash",    gender: "female")
george  = person!(first_name: "George",  last_name: "Reed",   gender: "male")
helen   = person!(first_name: "Helen",   last_name: "Reed",   gender: "female")
ivan    = person!(first_name: "Ivan",    last_name: "Moss",   gender: "male")
julia   = person!(first_name: "Julia",   last_name: "Moss",   gender: "female")

# Gen 3
charles = person!(first_name: "Charles", last_name: "Willow", gender: "male",   father: edmund, mother: hannah)
diana   = person!(first_name: "Diana",   last_name: "Ash",    gender: "female", father: arthur, mother: bridget)
edward  = person!(first_name: "Edward",  last_name: "Reed",   gender: "male",   father: george, mother: helen)
fiona   = person!(first_name: "Fiona",   last_name: "Moss",   gender: "female", father: ivan,   mother: julia)

# Sibling branches under Edmund + Hannah (wide descendants for Edmund)
person!(first_name: "Margaret", last_name: "Willow", gender: "female", father: edmund, mother: hannah)
person!(first_name: "Walter",   last_name: "Willow", gender: "male",   father: edmund, mother: hannah)

# Gen 2
henry = person!(first_name: "Henry", last_name: "Willow", gender: "male",   father: charles, mother: diana)
irene = person!(first_name: "Irene", last_name: "Reed",   gender: "female", father: edward,  mother: fiona)

# More children for Charles + Diana (branching under Charles)
person!(first_name: "Alice",  last_name: "Willow", gender: "female", father: charles, mother: diana)
person!(first_name: "Benjamin", last_name: "Willow", gender: "male", father: charles, mother: diana)

# Gen 1
oliver = person!(first_name: "Oliver", last_name: "Willow", gender: "male",   father: henry, mother: irene)
priya  = person!(first_name: "Priya",  last_name: "Vale",   gender: "female") # in-law root (no parents)

# Gen 0 — deepest leaf for ancestor chart (depth 4 from Nora → Edmund)
nora = person!(first_name: "Nora", last_name: "Vale", gender: "female", father: oliver, mother: priya)

# Nora's siblings (descendants under Oliver)
person!(first_name: "Leo",   last_name: "Vale", gender: "male",   father: oliver, mother: priya)
person!(first_name: "Maya",  last_name: "Vale", gender: "female", father: oliver, mother: priya)

# =============================================================================
# Pedigree B — Cross (man with multiple wives + children per wife)
# Victor has three wives:
#   Elena  → three children
#   Sofia  → two children
#   Amira  → one child
# One branch continues to a grandchild (Daniel → Sam).
# =============================================================================

victor = person!(first_name: "Victor", last_name: "Cross", gender: "male")
elena  = person!(first_name: "Elena",  last_name: "Cross", gender: "female")
sofia  = person!(first_name: "Sofia",  last_name: "Lane",  gender: "female")
amira  = person!(first_name: "Amira",  last_name: "Said",  gender: "female")

# First wife — Elena
daniel = person!(first_name: "Daniel", last_name: "Cross", gender: "male",   father: victor, mother: elena)
person!(first_name: "Eva",    last_name: "Cross", gender: "female", father: victor, mother: elena)
person!(first_name: "Peter",  last_name: "Cross", gender: "male",   father: victor, mother: elena)

# Second wife — Sofia
person!(first_name: "Marco", last_name: "Lane", gender: "male",   father: victor, mother: sofia)
person!(first_name: "Lucia", last_name: "Lane", gender: "female", father: victor, mother: sofia)

# Third wife — Amira (single child — "some wives have fewer kids")
person!(first_name: "Yasmin", last_name: "Said", gender: "female", father: victor, mother: amira)

# Grandchild under Daniel for nested multi-generation descendants
rosa = person!(first_name: "Rosa", last_name: "Diaz", gender: "female")
person!(first_name: "Sam", last_name: "Cross", gender: "male", father: daniel, mother: rosa)

# Also give Marco a spouse + child so one branch from the second wife nests further
marco = Person.find_by!(first_name: "Marco", last_name: "Lane")
nina  = person!(first_name: "Nina", last_name: "Cole", gender: "female")
person!(first_name: "Theo", last_name: "Lane", gender: "male", father: marco, mother: nina)


# =============================================================================
# Pedigree C — Berg (compact 3-level tree)
# =============================================================================

karl   = person!(first_name: "Karl",   last_name: "Berg", gender: "male")
ingrid = person!(first_name: "Ingrid", last_name: "Berg", gender: "female")

olaf  = person!(first_name: "Olaf",  last_name: "Berg", gender: "male",   father: karl, mother: ingrid)
helga = person!(first_name: "Helga", last_name: "Berg", gender: "female")

# Olaf + Helga have three children (horizontal descendants)
erik   = person!(first_name: "Erik",   last_name: "Berg", gender: "male",   father: olaf, mother: helga)
freya  = person!(first_name: "Freya",  last_name: "Berg", gender: "female", father: olaf, mother: helga)
bjorn  = person!(first_name: "Bjorn",  last_name: "Berg", gender: "male",   father: olaf, mother: helga)

astrid = person!(first_name: "Astrid", last_name: "Berg", gender: "female")
saga   = person!(first_name: "Saga",   last_name: "Berg", gender: "female", father: erik, mother: astrid)
finn   = person!(first_name: "Finn",   last_name: "Berg", gender: "male",   father: erik, mother: astrid)

# =============================================================================
# Pedigree D — edge cases
# =============================================================================

# Mother only (unknown father slot in ancestors UI)
clara = person!(first_name: "Clara", last_name: "Moss", gender: "female", mother: julia)

# Isolated people (no links) — empty ancestor + descendant panels
person!(first_name: "Isolde", last_name: "Alone", gender: "female")
person!(first_name: "Orion",  last_name: "Alone", gender: "male")

# =============================================================================
# Summary
# =============================================================================

puts "Seeded #{Person.count} people."
puts
puts "Open these to test the show page:"
puts "  Ancestors (deep)     → #{nora.display_name}            /people/#{nora.id}"
puts "  Descendants (wide)   → #{edmund.display_name}          /people/#{edmund.id}"
puts "  Multiple wives       → #{victor.display_name}          /people/#{victor.id}"
puts "                       → Elena: Daniel, Eva, Peter"
puts "                       → Sofia: Marco, Lucia"
puts "                       → Amira: Yasmin"
puts "  Compact family       → #{olaf.display_name}            /people/#{olaf.id}"
puts "  Partial parents      → #{clara.display_name}           /people/#{clara.id}"
puts "  Nested descendants   → #{daniel.display_name}          /people/#{daniel.id}"
puts "  Leaf (no kids)       → #{saga.display_name}            /people/#{saga.id}"
