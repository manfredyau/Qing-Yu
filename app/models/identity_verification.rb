class IdentityVerification < ApplicationRecord
  belongs_to :user
  belongs_to :reviewer, class_name: "AdminUser", optional: true

  has_one_attached :id_card_photo

  encrypts :id_number

  enum :status, { pending: 0, verified: 1, rejected: 2 }, default: :pending, validate: true

  validates :full_name, presence: true, length: { maximum: 30 }
  validates :id_number, presence: true
  validate :id_number_format, if: :id_number?

  before_validation :normalize_id_number

  scope :verified, -> { where(status: :verified) }

  def masked_id_number
    IdNumber.mask(id_number)
  end

  private
    def normalize_id_number
      self.id_number = id_number.to_s.strip.upcase
    end

    def id_number_format
      errors.add(:id_number, "身份证号格式不正确") unless IdNumber.valid?(id_number)
    end
end
