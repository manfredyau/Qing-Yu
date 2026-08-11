class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.references :user_a, null: false, foreign_key: { to_table: :users }
      t.references :user_b, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false  # 0 active 1 blocked
      t.datetime :last_message_at

      t.timestamps
    end
    add_index :matches, [ :user_a_id, :user_b_id ], unique: true
    add_index :matches, [ :last_message_at ]
  end
end
