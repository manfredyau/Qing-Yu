class Swipe < ApplicationRecord
  belongs_to :liker, class_name: "User", inverse_of: :swipes
  belongs_to :target, class_name: "User"

  enum :action, { like: 0, pass: 1 }, default: :like, validate: true

  validates :target_id, uniqueness: { scope: :liker_id }
end
