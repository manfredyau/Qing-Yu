class CreateSmsCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :sms_codes do |t|
      t.string :phone, null: false
      t.string :code_digest, null: false
      t.integer :purpose, default: 0, null: false      # 0 登录
      t.integer :attempts, default: 0, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at

      t.timestamps
    end
    add_index :sms_codes, [ :phone, :purpose, :expires_at ]
  end
end
