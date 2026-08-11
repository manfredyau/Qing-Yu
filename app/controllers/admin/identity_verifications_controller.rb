module Admin
  class IdentityVerificationsController < BaseController
    def index
      @verifications = IdentityVerification.order(created_at: :desc)
      @verifications = @verifications.where(status: params[:status]) if params[:status].present?
      @verifications = @verifications.includes(:user).limit(100)
    end

    def approve
      @verification = IdentityVerification.find(params[:id])
      @verification.update!(status: :verified, verified_at: Time.current, reviewer: admin_user, reviewed_at: Time.current, rejection_reason: nil)
      @verification.user.sync_verification_level!
      redirect_to admin_identity_verifications_path, notice: "已通过 #{@verification.user.display_name} 的实名认证"
    end

    def reject
      @verification = IdentityVerification.find(params[:id])
      @verification.update!(status: :rejected, reviewer: admin_user, reviewed_at: Time.current, rejection_reason: params[:reason].presence || "资料不属实")
      @verification.user.sync_verification_level!
      redirect_to admin_identity_verifications_path, notice: "已驳回 #{@verification.user.display_name} 的实名认证"
    end
  end
end
