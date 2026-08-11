class CreateSwipes < ActiveRecord::Migration[8.1]
  def change
    create_table :swipes do |t|
      t.references :liker, null: false, foreign_key: { to_table: :users }
      t.references :target, null: false, foreign_key: { to_table: :users }
      t.integer :action, default: 0, null: false  # 0 like 1 pass

      t.timestamps
    end
    add_index :swipes, [ :liker_id, :target_id ], unique: true
    add_index :swipes, [ :liker_id, :created_at ]
  end
end
