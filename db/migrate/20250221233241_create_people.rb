class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.integer :father_id
      t.integer :mother_id

      t.timestamps
    end

    add_index :people, :father_id
    add_index :people, :mother_id
  end
end
