# iOS 原生壳路径配置（Path Configuration）
# 由 turbo-ios 在启动时请求，决定各路径的呈现方式（push/modal/replace_root 等）
class HotwireNative::V1::Ios::PathConfigurationsController < ActionController::Base
  def show
    render json: {
      settings: {
        "haptics_enabled": true
      },
      rules: [
        # 认证表单与登录页 → 模态呈现
        {
          patterns: [ "/session/new$", "/login_code$", "/identity_verification/new$", "/education_verification/new$" ],
          properties: { context: "modal", pull_to_refresh_enabled: false }
        },
        # 资料编辑 → 默认 push
        {
          patterns: [ "^/profile/edit$" ],
          properties: { context: "default", pull_to_refresh_enabled: false }
        },
        # 聊天室 → push，从消息 Tab 栈内进入
        {
          patterns: [ "^/matches/[0-9]+$" ],
          properties: { context: "default", pull_to_refresh_enabled: false }
        },
        # 原生 Tab 根路径 → 替换根（避免堆栈累积）
        {
          patterns: [ "^/feed$", "^/matches$", "^/profile$" ],
          properties: { presentation: "replace_root" }
        },
        # 未登录 → 展示登录页
        {
          patterns: [ "^/session/new$" ],
          properties: { context: "modal" }
        }
      ]
    }
  end
end
