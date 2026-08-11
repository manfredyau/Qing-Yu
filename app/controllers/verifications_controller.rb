class VerificationsController < ApplicationController
  def show
    @identity = current_user.identity_verifications.order(created_at: :desc).first
    @education = current_user.education_verifications.order(created_at: :desc).first
  end
end
