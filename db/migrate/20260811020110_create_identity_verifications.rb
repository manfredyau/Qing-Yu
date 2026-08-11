class CreateIdentityVerifications < ActiveRecord::Migration[8.1]
  def change
    create_table :identity_verifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :id_number, null: false          # 加密存储
      t.string :provider, default: "mock", null: false
      t.integer :status, default: 0, null: false # 0 pending 1 verified 2 rejected
      t.string :rejection_reason
      t.jsonb :response                          # 服务商原始返回
      t.integer :reviewed_by
      t.datetime :reviewed_at
      t.datetime :verified_at

      t.timestamps
    end
    add_index :identity_verifications, [ :user_id, :status ]
  end
end
