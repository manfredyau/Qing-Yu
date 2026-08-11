# Hotwire Native 辅助方法（标题/视口/平台标识/内部链接处理）
module HotwireNativeHelper
  # 原生壳使用简洁标题，浏览器使用完整标题：
  #   <% content_for :hotwire_native_title, "登录" %>
  #   <% content_for :title, "登录 · 轻遇" %>
  def page_title
    [ (content_for(:hotwire_native_title) if turbo_native_app?), content_for(:title), @page_title,
      Rails.application.class.module_parent.name ].compact.first
  end

  # 原生壳与移动浏览器禁止缩放，避免输入抖动
  def viewport_meta_tag
    content = [ "width=device-width,initial-scale=1" ]
    content << "maximum-scale=1, user-scalable=0" if turbo_native_app? || mobile_user_agent?
    tag.meta(name: "viewport", content: content.join(","))
  end

  # 在 <html> 标签上标注原生平台
  def platform_identifier
    "data-hotwire-native" if turbo_native_app?
  end

  private
    def mobile_user_agent?
      request.user_agent.to_s.match?(/Mobile|Android|iPhone|iPad/i)
    end
end
