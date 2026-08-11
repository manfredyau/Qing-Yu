class CreateEducationVerifications < ActiveRecord::Migration[8.1]
  def change
    create_table :education_verifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :verify_code, null: false        # 学信网在线验证码（12 位）
      t.string :report_no, null: false          # 在线验证报告编号（16 位）
      t.string :school                          # 核验返回：学校
      t.string :degree                          # 核验返回：学历
      t.integer :education_level, default: 0, null: false
      t.string :provider, default: "mock", null: false
      t.integer :status, default: 0, null: false # 0 pending 1 verified 2 rejected
      t.string :rejection_reason
      t.jsonb :response
      t.integer :reviewed_by
      t.datetime :reviewed_at
      t.datetime :verified_at

      t.timestamps
    end
    add_index :education_verifications, [ :user_id, :status ]
  end
end
