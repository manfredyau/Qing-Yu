Rails.application.routes.draw do
  # 手机号+验证码登录
  resource :session, only: %i[ new create destroy ]
  resource :login_code, only: :create

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # 登录后入口
  root "home#index"
end
