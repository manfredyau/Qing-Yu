class IdentityVerificationsController < ApplicationController
  def new
    @verification = current_user.identity_verifications.build
  end

  def create
    service = Verification::IdCardVerificationService.new(current_user)
    @verification = service.verify(
      full_name: params[:identity_verification][:full_name],
      id_number: params[:identity_verification][:id_number],
      photo: params[:identity_verification][:id_card_photo]
    )

    if @verification.errors.any?
      render :new, status: :unprocessable_entity
    elsif @verification.verified?
      redirect_to verification_path, notice: "身份证实名认证通过，你已获得「已实名」标识 ✅"
    else
      redirect_to new_identity_verification_path, alert: "认证失败：#{@verification.rejection_reason}"
    end
  end
end
