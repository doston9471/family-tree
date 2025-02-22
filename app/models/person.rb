class Person < ApplicationRecord
  # Associations
  belongs_to :father, class_name: "Person", optional: true
  belongs_to :mother, class_name: "Person", optional: true
  has_many :children_as_father, class_name: "Person", foreign_key: "father_id"
  has_many :children_as_mother, class_name: "Person", foreign_key: "mother_id"

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, inclusion: { in: %w[male female], message: "must be 'male' or 'female'" }
  validates :first_name, uniqueness: {
    scope: [ :last_name, :father_id, :mother_id ],
    message: "already exists with the same parents"
  }
  validate :father_is_male
  validate :mother_is_female

  # Custom validation methods
  private def father_is_male
    errors.add(:father, "must be male") if father && father.gender != "male"
  end

  private def mother_is_female
    errors.add(:mother, "must be female") if mother && mother.gender != "female"
  end

  # Helper methods
  def display_name
    if father && mother
      "#{first_name} #{last_name} (child of #{father.first_name} and #{mother.first_name})"
    else
      "#{first_name} #{last_name}"
    end
  end

  def children
    gender == "male" ? children_as_father : children_as_mother
  end

  def ancestors_tree(depth = 0)
    output = "#{' ' * (depth * 2)}#{display_name}\n"
    if father
      output += "#{' ' * ((depth + 1) * 2)}Father: #{father.ancestors_tree(depth + 1)}"
    end
    if mother
      output += "#{' ' * ((depth + 1) * 2)}Mother: #{mother.ancestors_tree(depth + 1)}"
    end
    output
  end

  def descendants_tree(depth = 0)
    output = "#{' ' * (depth * 2)}#{display_name}\n"
    case gender
    when "male"
      # Get all wives (even those without children)
      wives = Person.where(id: children_as_father.pluck(:mother_id).uniq)
      wives.each do |wife|
        output += "#{' ' * ((depth + 1) * 2)}Wife: #{wife.display_name}\n"
        # Get children with this wife (if any)
        children_with_wife = children_as_father.where(mother_id: wife.id)
        if children_with_wife.any?
          children_with_wife.each do |child|
            output += child.descendants_tree(depth + 2)
          end
        end
      end
    when "female"
      # Get all husbands (even those without children)
      husbands = Person.where(id: children_as_mother.pluck(:father_id).uniq)
      husbands.each do |husband|
        output += "#{' ' * ((depth + 1) * 2)}Husband: #{husband.display_name}\n"
        # Get children with this husband (if any)
        children_with_husband = children_as_mother.where(father_id: husband.id)
        if children_with_husband.any?
          children_with_husband.each do |child|
            output += child.descendants_tree(depth + 2)
          end
        end
      end
    end
    output
  end
end
