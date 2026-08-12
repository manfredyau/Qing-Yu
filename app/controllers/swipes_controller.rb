class SwipesController < ApplicationController
  # 防刷：每分钟最多 100 次滑动（每日 10 次额度由服务层控制）
  rate_limit to: 100, within: 1.minute, only: :create,
    with: -> { render turbo_stream: turbo_stream.replace("feed-card", partial: "feeds/empty", locals: { remaining: 0 }), status: :too_many_requests }

  def create
    target = User.find(params[:target_id])
    @matched_user = nil
    swiped = false

    case params[:decision]
    when "like"
      @matched_user = target if MatcherService.like(current_user, target)
      swiped = true
    when "pass"
      MatcherService.pass(current_user, target)
      swiped = true
    end

    @service = RecommendationService.new(current_user)
    @service.consume!(target.id) if swiped # 从今日精选队列移除已滑候选
    @candidate = @service.exhausted? ? nil : @service.next_candidate
    @remaining = @service.remaining_today
  end
end
