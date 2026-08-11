class User < ApplicationRecord
  # 手机号+验证码为默认登录方式；密码为预留能力，故关闭自动校验
  has_secure_password validations: false

  has_many :sessions, as: :sessionable, dependent: :destroy

  normalizes :phone, with: ->(phone) { phone.to_s.strip.gsub(/\s+/, "") }
  normalizes :nickname, with: ->(nickname) { nickname.to_s.strip }

  validates :phone, presence: true, uniqueness: true,
            format: { with: /\A1[3-9]\d{9}\z/, message: "请输入正确的手机号" }
  validates :nickname, length: { maximum: 20, message: "昵称最长 20 个字" }
  validate :must_be_adult, if: :birthdate?

  enum :gender, { undisclosed: 0, male: 1, female: 2 }, default: :undisclosed, validate: true
  enum :status, { active: 1, suspended: 2 }, default: :active, validate: true
  enum :verification_level, { unverified: 0, id_verified: 1, fully_verified: 2 }, default: :unverified, validate: true
  enum :education_level, {
    not_disclosed: 0, high_school: 1, college: 2, bachelor: 3, master: 4, phd: 5
  }, default: :not_disclosed, validate: true
  enum :pref_gender, { any: 0, male: 1, female: 2 }, prefix: :pref, default: :female, validate: true

  scope :verified, -> { where(verification_level: [ :id_verified, :fully_verified ]) }
  scope :unverified, -> { where(verification_level: :unverified) }
  scope :active, -> { where(status: :active) }
  scope :searchable, -> { active.verified.where.not(gender: :undisclosed) }

  def verified?
    verification_level != "unverified"
  end

  def fully_verified?
    verification_level == "fully_verified"
  end

  def age
    return nil unless birthdate
    now = Date.current
    now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
  end

  def adult?
    age.present? && age >= 18
  end

  def display_name
    nickname.presence || "轻友#{phone.last(4)}"
  end

  private
    def must_be_adult
      errors.add(:birthdate, "必须年满 18 周岁") unless adult?
    end
end
