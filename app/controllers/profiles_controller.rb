class ProfilesController < ApplicationController
  # 「我的」页缓存版本：资料/认证/照片变化 → ETag 失效 → 返回新内容；编辑表单不缓存
  def cache_version_key
    return nil if action_name == "edit"

    [
      "profile", current_user.id,
      current_user.updated_at.to_i,
      current_user.identity_verifications.maximum(:updated_at).to_i,
      current_user.education_verifications.maximum(:updated_at).to_i,
      current_user.photos.maximum(:updated_at).to_i
    ].join(":")
  end

  # 「我的」页（原生 Tab 3）
  def show
    @identity = current_user.identity_verifications.order(created_at: :desc).first
    @education = current_user.education_verifications.order(created_at: :desc).first
  end

  def edit
  end

  def update
    if current_user.update(profile_params)
      redirect_to edit_profile_path, notice: "资料已保存"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def profile_params
      params.require(:user).permit(
        :nickname, :gender, :birthdate, :city, :height_cm, :education_level, :job, :bio,
        :pref_gender, :pref_age_min, :pref_age_max, :pref_distance_km, :pref_show_distance,
        interest_ids: []
      )
    end
end
