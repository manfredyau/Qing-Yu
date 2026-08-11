module Verification
  module IdCard
    # 腾讯云慧眼（人脸核身）接入点（占位）
    #
    # 接入步骤：
    #   1. 开通腾讯云「人脸核身 / 身份证二要素核验」，获取 SecretId/SecretKey
    #   2. 通过 tc3-hmac-sha256 签名调用 FaceId 相关 API
    #   3. 将返回结果包装为 Verification::Result
    class TencentProvider
      def verify(full_name:, id_number:, **)
        raise NotImplementedError, <<~MSG.squish
          腾讯云慧眼接入点尚未实现：
          请在配置 SecretId / SecretKey 后，按腾讯云文档实现本方法，
          并把 config.x.verification.id_card_provider 切换为 "tencent"。
        MSG
      end
    end
  end
end
