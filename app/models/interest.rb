class Interest < ApplicationRecord
  has_many :profile_interests, dependent: :destroy
  has_many :users, through: :profile_interests

  validates :name, presence: true, uniqueness: true, length: { maximum: 20 }

  scope :grouped, -> { order(:category, :name) }
end
