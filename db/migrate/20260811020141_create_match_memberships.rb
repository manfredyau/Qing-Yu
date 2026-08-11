class CreateMatchMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :match_memberships do |t|
      t.references :match, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :last_read_at
      t.datetime :muted_at

      t.timestamps
    end
    add_index :match_memberships, [ :match_id, :user_id ], unique: true
  end
end
