# Hotwire Native 设备识别：原生壳请求使用 :native 视图变体
module DeviceFormat
  extend ActiveSupport::Concern

  included do
    before_action :set_variant
  end

  private
    def set_variant
      request.variant = :native if turbo_native_app?
    end
end
