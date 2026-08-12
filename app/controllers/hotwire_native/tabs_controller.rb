# 原生壳 Tab 重定向：按登录状态把绝对路径指到正确的页面。
# 加 _ts 参数绕过顽固的 WebView HTTP 缓存（否则多个 Tab 可能共享同一份旧缓存）。
class HotwireNative::TabsController < ActionController::Base
  def tab1
    redirect_to feed_path(_ts: Time.current.to_i)
  end

  def tab2
    redirect_to matches_path(_ts: Time.current.to_i)
  end

  def tab3
    redirect_to profile_path(_ts: Time.current.to_i)
  end
end
