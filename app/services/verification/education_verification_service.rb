module Verification
  # 学信网（学历/学籍）认证服务：调服务商核验 + 落库 + 更新用户认证等级
  class EducationVerificationService
    def initialize(user, provider_name: nil)
      @user = user
      @provider_name = provider_name || Rails.application.config.x.verification.education_provider
    end

    # 返回 EducationVerification 记录（状态同 IdCardVerificationService）
    def verify(verify_code:, report_no:)
      record = EducationVerification.new(
        user: @user, verify_code: verify_code.to_s.strip,
        report_no: report_no.to_s.strip, provider: @provider_name
      )

      return record unless record.valid?

      result = provider.verify(verify_code: record.verify_code, report_no: record.report_no)

      if result.success
        record.status = :verified
        record.verified_at = Time.current
        record.rejection_reason = nil
        record.response = result.data
        record.school = result.data[:school]
        record.degree = result.data[:degree]
        record.education_level = result.data[:education_level]
        record.save!

        # V2 = 身份证 + 学信网；若身份证未通过则保持当前等级（学历徽章单独展示）
        @user.update!(verification_level: :fully_verified, verified_at: Time.current) if @user.identity_verifications.verified.exists?
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
        EducationProvider.for(@provider_name)
      end
  end
end
