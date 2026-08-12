class ProfilesController < ApplicationController
  # 「我的」页缓存 5 分钟（资料变化不频繁）；编辑表单不缓存
  def page_cache_ttl
    action_name == "show" ? 5.minutes.to_i : nil
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
