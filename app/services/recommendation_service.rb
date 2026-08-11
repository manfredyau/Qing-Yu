# 轻量推荐服务：每日限量精选，减少信息过载
class RecommendationService
  DAILY_LIMIT = 10

  def initialize(user)
    @user = user
  end

  # 候选规则：已实名、资料完整、目标性别、年龄偏好、未划过/未拉黑/非本人
  def candidates(limit: 1)
    base = User.searchable
               .where.not(id: @user.id)
               .where.not(id: swiped_ids)
               .where.not(id: blocked_ids)
               .where.not(id: blocked_by_ids)

    base = base.where(gender: @user.pref_gender) unless @user.pref_any?
    base = base.where(birthdate: age_range)

    base.order("RANDOM()").limit(limit)
  end

  def next_candidate
    candidates.first
  end

  def swipes_today
    @user.swipes.where("created_at >= ?", Time.current.beginning_of_day).count
  end

  def remaining_today
    [ DAILY_LIMIT - swipes_today, 0 ].max
  end

  def exhausted?
    remaining_today <= 0
  end

  private
    def swiped_ids
      @user.swipes.pluck(:target_id)
    end

    def blocked_ids
      @user.blocks.pluck(:blocked_id)
    end

    def blocked_by_ids
      Block.where(blocked_id: @user.id).pluck(:blocker_id)
    end

    # 年龄偏好 → 出生日期区间（age ∈ [pref_age_min, pref_age_max]）
    def age_range
      (@user.pref_age_max + 1).years.ago.to_date..@user.pref_age_min.years.ago.to_date
    end
end
