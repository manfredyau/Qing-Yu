module Verification
  # 身份证实名认证服务：调服务商核验 + 落库 + 更新用户认证等级
  class IdCardVerificationService
    def initialize(user, provider_name: nil)
      @user = user
      @provider_name = provider_name || Rails.application.config.x.verification.id_card_provider
    end

    # 返回 IdentityVerification 记录：
    # - 表单校验失败：record.errors 有内容
    # - 核验成功：status = verified
    # - 核验失败：status = rejected，rejection_reason 有内容
    def verify(full_name:, id_number:, photo: nil)
      record = IdentityVerification.new(
        user: @user, full_name: full_name.to_s.strip,
        id_number: id_number.to_s.strip, provider: @provider_name
      )
      record.id_card_photo.attach(photo) if photo

      return record unless record.valid?

      result = provider.verify(full_name: record.full_name, id_number: record.id_number)

      if result.success
        record.status = :verified
        record.verified_at = Time.current
        record.rejection_reason = nil
        record.response = result.data
        record.save!

        # V1 = 身份证；若学信网也已通过则升级为 V2
        new_level = @user.education_verifications.verified.exists? ? :fully_verified : :id_verified
        @user.update!(verification_level: new_level, verified_at: Time.current)
      else
        record.status = :rejected
        record.rejection_reason = result.message
        record.response = result.data
        record.save!
      end

      record
    end

    private
      def provider
        IdCardProvider.for(@provider_name)
      end
  end
end
