module Admin
  class EducationVerificationsController < BaseController
    def index
      @verifications = EducationVerification.order(created_at: :desc)
      @verifications = @verifications.where(status: params[:status]) if params[:status].present?
      @verifications = @verifications.includes(:user).limit(100)
    end

    def approve
      @verification = EducationVerification.find(params[:id])
      @verification.update!(status: :verified, verified_at: Time.current, reviewer: admin_user, reviewed_at: Time.current, rejection_reason: nil)
      @verification.user.sync_verification_level!
      redirect_to admin_education_verifications_path, notice: "已通过学信网核验"
    end

    def reject
      @verification = EducationVerification.find(params[:id])
      @verification.update!(status: :rejected, reviewer: admin_user, reviewed_at: Time.current, rejection_reason: params[:reason].presence || "学籍信息不符")
      @verification.user.sync_verification_level!
      redirect_to admin_education_verifications_path, notice: "已驳回学信网核验"
    end
  end
end
