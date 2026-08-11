class CreateInterests < ActiveRecord::Migration[8.1]
  def change
    create_table :interests do |t|
      t.string :name, null: false
      t.string :category

      t.timestamps
    end
    add_index :interests, :name, unique: true
  end
end
