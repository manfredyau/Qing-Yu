class ApplicationController < ActionController::Base
  include Authentication
  include DeviceFormat

  # 表单令牌过期（长时间停留/多标签页导致）→ 友好提示并返回，而不是技术错误页
  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to request.referer.presence || root_path,
                alert: "页面已过期，请刷新后重试。", status: :see_other
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # 原生壳（Hotwire Native WebView）的 UA 会被 browser gem 误判为旧浏览器，故豁免
  allow_browser versions: :modern, if: -> { !turbo_native_app? }

  # 页面缓存（牵手式：ETag/304 条件请求，而非固定 TTL）
  # 子类覆写 cache_version_key 返回业务版本字符串 → 进入条件缓存：
  # fresh_when 设置 weak ETag（自动叠加 importmap/template digest）+
  # Cache-Control: private, max-age=0, must-revalidate，WebView 每次回源带
  # If-None-Match，无变化 → 304 秒开，有变化 → 立即拿新页面，永不过时。
  before_action :set_page_cache

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :admin_user, :turbo_native_app?

  private
    # 页面缓存版本 key。子类覆盖此方法返回业务版本字符串；返回 nil 表示不缓存（no-store）。
    # 版本必须覆盖所有会让页面内容变化的维度（如剩余额度、资料/认证/消息状态），
    # 任何变化 → ETag 变化 → 304 失效 → 客户端立即拿到新页面。
    def cache_version_key
      nil
    end

    def set_page_cache
      return if request.format.turbo_stream? # 流式响应（滑动/消息）不缓存

      if (version = cache_version_key)
        fresh_when etag: version
      else
        # WebView 对 no-store 支持不一致，加全套反缓存头
        response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
      end
    end
    def current_user
      Current.user
    end

    def admin_user
      Current.admin_user
    end

    # Hotwire Native 壳应用（iOS/Android）的 UA 含 "Turbo Native"
    def turbo_native_app?
      request.user_agent.to_s.match?(/Turbo Native/i)
    end
end
