class EducationVerificationsController < ApplicationController
  def new
    @verification = current_user.education_verifications.build
  end

  def create
    service = Verification::EducationVerificationService.new(current_user)
    @verification = service.verify(
      verify_code: params[:education_verification][:verify_code],
      report_no: params[:education_verification][:report_no]
    )

    if @verification.errors.any?
      render :new, status: :unprocessable_entity
    elsif @verification.verified?
      redirect_to verification_path, notice: "学信网学籍核验通过：#{@verification.school} · #{@verification.degree} ✅"
    else
      redirect_to new_education_verification_path, alert: "核验失败：#{@verification.rejection_reason}"
    end
  end
end
