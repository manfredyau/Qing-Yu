class ApplicationController < ActionController::Base
  include Authentication
  include DeviceFormat
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # 原生壳（Hotwire Native WebView）的 UA 会被 browser gem 误判为旧浏览器，故豁免
  allow_browser versions: :modern, if: -> { !turbo_native_app? }

  # 页面级 TTL 缓存：各控制器通过 page_cache_ttl 定制过期时间（秒）
  before_action :set_page_cache

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :admin_user, :turbo_native_app?

  private
    # 页面缓存有效期（秒）。子类覆盖此方法定制；返回 nil 表示不缓存（no-store）。
    # 配合布局中的 turbo-cache-control no-cache 元标签：Turbo 不做快照缓存，
    # 但 HTTP 层在 TTL 内的重复请求直接命中缓存（含返回导航），TTL 过后自动回源刷新。
    def page_cache_ttl
      nil
    end

    def set_page_cache
      return if request.format.turbo_stream?   # 流式响应（滑动/消息）不缓存

      ttl = page_cache_ttl
      response.headers["Cache-Control"] = ttl ? "private, max-age=#{ttl}" : "no-store"
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
