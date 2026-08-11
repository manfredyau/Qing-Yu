class SmsCode < ApplicationRecord
  LOGIN_TTL = 5.minutes
  MAX_ATTEMPTS = 5

  enum :purpose, { login: 0 }, default: :login, validate: true

  validates :phone, format: { with: /\A1[3-9]\d{9}\z/, message: "请输入正确的手机号" }

  scope :unconsumed, -> { where(consumed_at: nil) }

  # 生成验证码并返回 [明文验证码, 记录]，明文仅用于发送短信（Mock 模式下写入日志）
  def self.issue_for_login(phone)
    plaintext = format("%06d", SecureRandom.random_number(1_000_000))
    record = create!(
      phone: phone,
      purpose: :login,
      code_digest: Digest::SHA256.hexdigest(plaintext),
      expires_at: LOGIN_TTL.from_now
    )
    [ plaintext, record ]
  end

  def valid_code?(plaintext)
    return false if consumed? || expired? || attempts_exhausted?
    ActiveSupport::SecurityUtils.secure_compare(
      code_digest, Digest::SHA256.hexdigest(plaintext.to_s.strip)
    )
  end

  def consumed?
    consumed_at.present?
  end

  def record_attempt!
    increment!(:attempts)
  end

  def consume!
    update!(consumed_at: Time.current)
  end

  def expired?
    expires_at <= Time.current
  end

  def attempts_exhausted?
    attempts >= MAX_ATTEMPTS
  end
end
