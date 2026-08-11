class Block < ApplicationRecord
  belongs_to :blocker, class_name: "User", inverse_of: :blocks
  belongs_to :blocked, class_name: "User"

  validates :blocked_id, uniqueness: { scope: :blocker_id }
end
