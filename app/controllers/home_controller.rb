class HomeController < ApplicationController
  def index
    # 已实名 + 资料完善 → 直接进入每日推荐；否则留在首页引导
    redirect_to feed_path if current_user.verified? && current_user.profile_complete?
  end
end
