# 开发/测试环境专用：重置当前用户的今日推荐（滑卡测试用，生产环境无路由且控制器拒绝）
class Dev::ResetsController < ApplicationController
  before_action :require_non_production

  def recommendations
    current_user.swipes.where("created_at >= ?", Time.current.beginning_of_day).delete_all
    Rails.cache.delete("rec:queue:v2:#{current_user.id}:#{Date.current}")
    redirect_to feed_path, notice: "已重置今日推荐（开发模式）"
  end

  private
    def require_non_production
      raise ActionController::RoutingError, "仅开发/测试环境可用" if Rails.env.production?
    end
end
