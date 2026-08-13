# 原生壳 Tab 重定向：按登录状态把绝对路径指到正确的页面。
# tab1（推荐）加 _ts 参数绕过 WebView 持久缓存（内容每次都会变，保持新鲜）；
# tab2/tab3（消息/我的）用稳定 URL，让客户端 HTTP 缓存（TTL + ETag 条件刷新）生效，秒开不转圈。
class HotwireNative::TabsController < ActionController::Base
  def tab1
    redirect_to feed_path(_ts: Time.current.to_i)
  end

  def tab2
    redirect_to matches_path
  end

  def tab3
    redirect_to profile_path
  end
end
