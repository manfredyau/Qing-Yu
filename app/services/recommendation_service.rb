# 轻量推荐服务：每日限量精选，减少信息过载
#
# 牵手式思路：每日推荐 = 服务端预生成的「今日精选」队列快照。
# - queue：首次访问时按偏好生成当日候选并缓存（key 含日期 → 北京时间 00:00 自动重置），
#   当天内顺序稳定、不逐请求重算；滑卡时 consume! 消费，避免顺序乱跳。
# - 剩余额度仍按当日滑动计数（DAILY_LIMIT - swipes_today），与既有「滑完候选取 / 滑满 10 次」两种空态语义一致。
# 并发消费（读-改-写）非原子，当前规模可接受；生产高并发可换 Redis + 原子操作。
class RecommendationService
  DAILY_LIMIT = 10
  QUEUE_EXPIRES_IN = 30.hours # 覆盖跨天窗口，真正失效靠 key 里的日期

  def initialize(user)
    @user = user
  end

  # 当日候选队列：已实名、资料完整、目标性别、年龄偏好、未划过/未拉黑/非本人
  def queue
    Rails.cache.fetch(queue_key, expires_in: QUEUE_EXPIRES_IN) do
      base = User.searchable
                 .where.not(id: @user.id)
                 .where.not(id: swiped_ids)
                 .where.not(id: blocked_ids)
                 .where.not(id: blocked_by_ids)

      base = base.where(gender: @user.pref_gender) unless @user.pref_any?
      base = base.where(birthdate: age_range)

      base.order("RANDOM()").limit(DAILY_LIMIT).pluck(:id)
    end
  end

  # 滑动后从今日队列移除该候选；返回是否在队列中（幂等，重复提交不报错）
  def consume!(target_id)
    remaining = queue
    return false unless remaining.delete(target_id)

    # 空队列不写缓存（否则会把空状态锁 30 小时，且候选池变化后无法自动恢复）
    if remaining.empty?
      Rails.cache.delete(queue_key)
    else
      Rails.cache.write(queue_key, remaining, expires_in: QUEUE_EXPIRES_IN)
    end
    true
  end

  def next_candidate
    id = queue.first
    id && User.find_by(id: id)
  end

  def swipes_today
    @user.swipes.where("created_at >= ?", Time.current.beginning_of_day).count
  end

  # 今日剩余额度（当日滑动数驱动的额度，与队列长度解耦）
  def remaining_today
    [ DAILY_LIMIT - swipes_today, 0 ].max
  end

  # 额度用尽，或队列为空（没有可滑的候选）
  def exhausted?
    remaining_today <= 0 || queue.empty?
  end

  private
    def queue_key
      "rec:queue:v2:#{@user.id}:#{Date.current}"
    end

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
