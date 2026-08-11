class EducationVerification < ApplicationRecord
  belongs_to :user
  belongs_to :reviewer, class_name: "AdminUser", foreign_key: :reviewed_by, optional: true

  enum :status, { pending: 0, verified: 1, rejected: 2 }, default: :pending, validate: true
  enum :education_level, User.education_levels, default: :not_disclosed, validate: true

  validates :verify_code, presence: true,
            format: { with: /\A\d{12}\z/, message: "在线验证码应为 12 位数字" }
  validates :report_no, presence: true,
            length: { is: 16, message: "报告编号应为 16 位" }

  scope :verified, -> { where(status: :verified) }
end
