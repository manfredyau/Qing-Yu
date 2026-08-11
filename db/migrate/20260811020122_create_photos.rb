class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :position, default: 0, null: false
      t.integer :status, default: 0, null: false   # 0 pending 1 approved 2 rejected
      t.boolean :primary, default: false, null: false
      t.string :rejection_reason
      t.integer :reviewed_by
      t.datetime :reviewed_at

      t.timestamps
    end
    add_index :photos, [ :user_id, :status, :position ]
  end
end
