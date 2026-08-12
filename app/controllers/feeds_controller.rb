class FeedsController < ApplicationController
  # 推荐页缓存 3 小时（候选/额度变化慢，TTL 内秒开、过后自动刷新）
  def page_cache_ttl
    3.hours.to_i
  end

  def show
    @service = RecommendationService.new(current_user)
    @candidate = @service.exhausted? ? nil : @service.next_candidate
    @remaining = @service.remaining_today
  end
end
