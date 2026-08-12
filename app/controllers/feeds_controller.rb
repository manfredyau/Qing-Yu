class FeedsController < ApplicationController
  # 推荐页缓存版本：滑卡（剩余额度）、认证完成、资料变更都会让版本变化 → ETag 失效 → 返回新页面
  def cache_version_key
    service = RecommendationService.new(current_user)
    [
      "feed", current_user.id, Date.current.to_s,
      service.remaining_today,
      current_user.updated_at.to_i,
      current_user.identity_verifications.maximum(:updated_at).to_i,
      current_user.education_verifications.maximum(:updated_at).to_i
    ].join(":")
  end

  def show
    @service = RecommendationService.new(current_user)
    @candidate = @service.exhausted? ? nil : @service.next_candidate
    @remaining = @service.remaining_today
  end
end
