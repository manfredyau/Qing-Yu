class FeedsController < ApplicationController
  # 推荐页不缓存（no-store）：资料状态变化频繁（完善→推荐卡片），
  # 客户端 Tab 已有 lazyLoadTabs 保持会话内秒开，HTTP 缓存弊大于利。
  def cache_version_key
    nil
  end

  def show
    @service = RecommendationService.new(current_user)
    @candidate = @service.exhausted? ? nil : @service.next_candidate
    @remaining = @service.remaining_today
  end
end
