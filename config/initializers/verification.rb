# 认证服务商选择（通过环境变量切换，生产环境接入真实服务商）
Rails.application.config.x.verification = ActiveSupport::OrderedOptions.new
Rails.application.config.x.verification.id_card_provider = ENV.fetch("ID_CARD_PROVIDER", "mock")
Rails.application.config.x.verification.education_provider = ENV.fetch("EDUCATION_PROVIDER", "mock")
