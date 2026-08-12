class ApplicationController < ActionController::Base
  include Authentication
  include DeviceFormat
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # 原生壳（Hotwire Native WebView）的 UA 会被 browser gem 误判为旧浏览器，故豁免
  allow_browser versions: :modern, if: -> { !turbo_native_app? }

  # 登录后页面禁用 HTTP 缓存（配合 turbo-cache-control 元标签，避免过期状态显示）
  before_action :set_no_store

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :admin_user, :turbo_native_app?

  private
    def set_no_store
      response.headers["Cache-Control"] = "no-store" if authenticated?
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
