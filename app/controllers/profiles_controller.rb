class ProfilesController < ApplicationController
  # 我的页缓存：TTL 1 分钟内秒开；stale 窗口 24 小时（自己的资料自己改，版本比对兜底）
  def page_cache_ttl
    60
  end

  def page_cache_stale
    24.hours.to_i
  end

  # 「我的」页缓存版本：资料/认证/照片变化 → ETag 失效 → 返回新内容；编辑表单/更新动作不缓存
  def cache_version_key
    return nil unless action_name == "show"

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
      if current_user.profile_complete?
        redirect_to edit_profile_path, notice: "资料已保存"
      else
        # 保存成功但资料仍不完整：明确告诉用户还差什么（避免 feed 显示"完善资料"时不明所以）
        redirect_to edit_profile_path, alert: "资料已保存，还差：#{current_user.missing_profile_parts.join('、')}"
      end
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
