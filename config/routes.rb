Rails.application.routes.draw do
  # 手机号+验证码登录
  resource :session, only: %i[ new create destroy ]
  resource :login_code, only: :create

  # 实名认证（身份证 / 学信网）
  resource :verification, only: :show
  resource :identity_verification, only: %i[ new create ]
  resource :education_verification, only: %i[ new create ]

  # 个人资料与照片
  resource :profile, only: %i[ edit update ]
  resources :photos, only: %i[ create destroy ] do
    patch :set_primary, on: :member
  end

  # 轻量推荐（每日限额 + 滑卡）
  resource :feed, only: :show, controller: "feeds"
  resources :swipes, only: :create
  resources :matches, only: %i[ index show ] do
    resources :messages, only: :create
  end

  # 管理后台
  namespace :admin do
    root "dashboard#index"
    resource :session, only: %i[ new create destroy ], controller: "sessions"
    resources :identity_verifications, only: :index do
      patch :approve, on: :member
      patch :reject, on: :member
    end
    resources :education_verifications, only: :index do
      patch :approve, on: :member
      patch :reject, on: :member
    end
    resources :photos, only: :index do
      patch :approve, on: :member
      patch :reject, on: :member
    end
    resources :users, only: %i[ index show ] do
      patch :suspend, on: :member
      patch :unsuspend, on: :member
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # 登录后入口
  root "home#index"
end
