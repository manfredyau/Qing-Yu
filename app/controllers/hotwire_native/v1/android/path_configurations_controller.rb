# Android 原生壳路径配置（turbo-android 使用独立的 Path Configuration 格式）
class HotwireNative::V1::Android::PathConfigurationsController < ActionController::Base
  def show
    render json: {
      settings: {
        "haptics_enabled": true
      },
      rules: [
        {
          patterns: [ "/session/new", "/login_code", "/identity_verification/new", "/education_verification/new" ],
          properties: { context: "modal", pull_to_refresh_enabled: false }
        },
        {
          patterns: [ "^/matches/[0-9]+" ],
          properties: { context: "default", pull_to_refresh_enabled: true }
        },
        {
          # 推荐页：关闭下拉刷新。SwipeRefreshLayout 会在内容顶部时接管向下手势，
          # 导致向左下/右下方向的滑卡被拦截；推荐页无页面滚动，不需要下拉刷新
          patterns: [ "^/feed" ],
          properties: { presentation: "replace_root", pull_to_refresh_enabled: false }
        },
        {
          # Tab 根页面开启下拉刷新，可手动刷新过期状态（如登录前的残留页面）
          patterns: [ "^/matches$", "^/profile$" ],
          properties: { presentation: "replace_root", pull_to_refresh_enabled: true }
        }
      ]
    }
  end
end
