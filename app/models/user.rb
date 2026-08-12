class User < ApplicationRecord
  # 手机号+验证码为默认登录方式；密码为预留能力，故关闭自动校验
  has_secure_password validations: false

  has_many :sessions, as: :sessionable, dependent: :destroy
  has_many :identity_verifications, dependent: :destroy
  has_many :education_verifications, dependent: :destroy
  has_many :photos, dependent: :destroy
  has_many :profile_interests, dependent: :destroy
  has_many :interests, through: :profile_interests
  has_many :swipes, foreign_key: :liker_id, dependent: :destroy, inverse_of: :liker
  has_many :matches_a, class_name: "Match", foreign_key: :user_a_id, dependent: :destroy, inverse_of: :user_a
  has_many :matches_b, class_name: "Match", foreign_key: :user_b_id, dependent: :destroy, inverse_of: :user_b
  has_many :blocks, foreign_key: :blocker_id, dependent: :destroy, inverse_of: :blocker

  def matches
    Match.where("user_a_id = ? OR user_b_id = ?", id, id)
  end

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

  # ---- 资料 ----

  # 头像/照片：优先已审核照片；仅有待审核照片时也返回（本人可见自己的上传，
  # 其他用户查看时由视图标注「审核中」，审核不再阻塞用户提交资料）
  def avatar_photo
    photos.approved.primary.first || photos.approved.ordered.first || photos.pending.ordered.first
  end

  def has_avatar?
    avatar_photo.present?
  end

  # 资料完整度：昵称/生日/性别/城市/照片/标签 齐备（照片上传即可，审核结果只影响他人可见性）
  def profile_complete?
    nickname.present? && birthdate.present? && !undisclosed? && city.present? &&
      photos.any? && interests.any?
  end

  # 资料还缺什么（面向用户的可读提示）
  def missing_profile_parts
    parts = []
    parts << "昵称" unless nickname.present?
    parts << "生日" unless birthdate.present?
    parts << "性别" if undisclosed?
    parts << "城市" unless city.present?
    parts << "照片" unless photos.any?
    parts << "兴趣标签" unless interests.any?
    parts
  end

  def verified_school
    education_verifications.verified.order(verified_at: :desc).first&.school
  end

  def height_label
    height_cm ? "#{height_cm} cm" : nil
  end

  def gender_label
    { "undisclosed" => "未设置", "male" => "男", "female" => "女" }[gender]
  end

  class << self
    def education_level_label(key)
      {
        "not_disclosed" => "不填", "high_school" => "高中", "college" => "大专",
        "bachelor" => "本科", "master" => "硕士", "phd" => "博士"
      }[key.to_s]
    end
  end

  # 依据已通过的认证记录重算认证等级（后台人工复核后调用）
  def sync_verification_level!
    level = identity_verifications.verified.exists? ? :id_verified : :unverified
    level = :fully_verified if level == :id_verified && education_verifications.verified.exists?

    attrs = { verification_level: level }
    attrs[:verified_at] = level == :unverified ? nil : Time.current
    update!(attrs)
  end

  private
    def must_be_adult
      errors.add(:birthdate, "必须年满 18 周岁") unless adult?
    end
end
