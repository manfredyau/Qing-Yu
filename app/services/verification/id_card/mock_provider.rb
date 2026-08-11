module Verification
  module IdCard
    # Mock 服务商：模拟公安系统「姓名+身份证号」二要素核验
    # - 校验 18 位身份证校验位（真实算法）
    # - 内置姓名黑名单以演示"核验失败"路径
    # 生产环境替换为阿里云/腾讯云实人认证，接口签名不变。
    class MockProvider
      # 模拟公安系统可能拒绝的姓名（演示用）
      REJECT_NAMES = %w[李四 测试失败 无效].freeze

      def verify(full_name:, id_number:, **)
        return IdCardProvider::Result.new(false, "姓名不能为空", nil) if full_name.blank?
        return IdCardProvider::Result.new(false, "身份证号格式不正确", nil) unless IdNumber.valid?(id_number)
        if REJECT_NAMES.any? { |name| full_name.include?(name) }
          return IdCardProvider::Result.new(false, "姓名与证件号不匹配（Mock 拒绝）", nil)
        end

        IdCardProvider::Result.new(true, "核验通过", { masked_id_number: IdNumber.mask(id_number) })
      end
    end
  end
end
