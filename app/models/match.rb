class Match < ApplicationRecord
  belongs_to :user_a, class_name: "User", inverse_of: :matches_a
  belongs_to :user_b, class_name: "User", inverse_of: :matches_b

  enum :status, { active: 0, blocked: 1 }, default: :active, validate: true

  scope :active, -> { where(status: :active) }
  scope :recent, -> { order(Arel.sql("COALESCE(last_message_at, created_at) DESC")) }

  # 给定用户的对端
  def other_user(current_user)
    current_user.id == user_a_id ? user_b : user_a
  end

  def participants
    [ user_a, user_b ]
  end

  def involves?(user)
    user_a_id == user.id || user_b_id == user.id
  end
end
