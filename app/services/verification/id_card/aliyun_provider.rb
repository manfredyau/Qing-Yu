module Verification
  module IdCard
    # 阿里云实人认证接入点（占位）
    #
    # 接入步骤：
    #   1. 开通阿里云「实人认证 / 身份证核验」产品，获取 AccessKey
    #   2. 将 ACCESS_KEY_ID / ACCESS_KEY_SECRET 注入环境变量
    #   3. 按阿里云 OpenAPI 签名流程调用（aliyun-sdk-core / 手写 V3 签名）
    #   4. 将返回结果包装为 Verification::Result
    class AliyunProvider
      def verify(full_name:, id_number:, **)
        raise NotImplementedError, <<~MSG.squish
          阿里云实人认证接入点尚未实现：
          请在配置 ACCESS_KEY_ID / ACCESS_KEY_SECRET 后，按阿里云文档实现本方法，
          并把 config.x.verification.id_card_provider 切换为 "aliyun"。
        MSG
      end
    end
  end
end
