class Match < ApplicationRecord
  belongs_to :user_a, class_name: "User", inverse_of: :matches_a
  belongs_to :user_b, class_name: "User", inverse_of: :matches_b

  has_many :messages, dependent: :destroy
  has_many :match_memberships, dependent: :destroy

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

  def membership_for(user)
    match_memberships.find_by(user: user)
  end

  def unread_count_for(user)
    scope = messages.where.not(sender_id: user.id)
    membership = membership_for(user)
    return scope.count unless membership&.last_read_at

    scope.where("created_at > ?", membership.last_read_at).count
  end
end
