namespace :hotwire_native do
  namespace :v1 do
    namespace :android do
      resource :path_configuration, only: :show
    end
    namespace :ios do
      resource :path_configuration, only: :show
    end
  end

  # 原生底部 Tab（3 个）：每日推荐 / 消息 / 我的
  get "tab1", to: "tabs#tab1"
  get "tab2", to: "tabs#tab2"
  get "tab3", to: "tabs#tab3"
end
