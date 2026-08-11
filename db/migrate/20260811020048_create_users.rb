class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :phone, null: false
      # 可选密码（手机号+验证码为默认登录方式，密码为预留能力）
      t.string :password_digest

      # 基础资料
      t.string :nickname
      t.integer :gender, default: 0, null: false       # 0 未设置 1 男 2 女
      t.date :birthdate
      t.string :city
      t.integer :height_cm
      t.integer :education_level, default: 0, null: false # 0 未填 1 高中 2 大专 3 本科 4 硕士 5 博士
      t.string :job
      t.text :bio
      t.bigint :avatar_photo_id

      # 实名认证等级（V0 未认证 / V1 身份证 / V2 身份证+学信网）
      t.integer :verification_level, default: 0, null: false
      t.datetime :verified_at

      # 择偶偏好
      t.integer :pref_gender, default: 2, null: false  # 0 不限 1 男 2 女
      t.integer :pref_age_min, default: 18, null: false
      t.integer :pref_age_max, default: 45, null: false
      t.integer :pref_distance_km, default: 50, null: false
      t.boolean :pref_show_distance, default: true, null: false

      # 状态
      t.integer :status, default: 1, null: false       # 1 正常 2 封禁
      t.datetime :last_active_at

      t.timestamps
    end
    add_index :users, :phone, unique: true
    add_index :users, [ :gender, :verification_level, :status ]
  end
end
