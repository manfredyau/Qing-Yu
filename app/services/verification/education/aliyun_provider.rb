module Verification
  module Education
    # 阿里云市场「学信网验证」服务接入点（占位）
    # 与 XuexinProvider 类似：通过阿里云云市场 AppCode 调用核验 API。
    class AliyunProvider
      def verify(verify_code:, report_no:, **)
        raise NotImplementedError, <<~MSG.squish
          阿里云市场学信网核验接入点尚未实现：
          请配置 AppCode 后按服务商文档实现本方法，
          并把 config.x.verification.education_provider 切换为 "aliyun"。
        MSG
      end
    end
  end
end
