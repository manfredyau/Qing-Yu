# 原生壳 Tab 重定向：按登录状态把绝对路径指到正确的页面
class HotwireNative::TabsController < ActionController::Base
  def tab1
    redirect_to feed_path
  end

  def tab2
    redirect_to matches_path
  end

  def tab3
    redirect_to profile_path
  end
end
