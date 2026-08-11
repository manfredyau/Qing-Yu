class MatchMembership < ApplicationRecord
  belongs_to :match
  belongs_to :user

  validates :user_id, uniqueness: { scope: :match_id }
end
