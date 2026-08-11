module Verification
  module Education
    # 学信网报告核验 API 接入点（占位）
    #
    # 学信网官方无开放的个人核验 API，通常通过云市场第三方（阿里云市场等）
    # 的「学信网在线验证报告核验」服务调用。接入步骤：
    #   1. 购买云市场核验服务，获取 AppCode
    #   2. 调用核验 API（POST /verify?verify_code=&report_no=）
    #   3. 解析返回的学校/学历信息，包装为 Verification::Result
    class XuexinProvider
      def verify(verify_code:, report_no:, **)
        raise NotImplementedError, <<~MSG.squish
          学信网报告核验接入点尚未实现：
          请配置云市场 AppCode 后按服务商文档实现本方法，
          并把 config.x.verification.education_provider 切换为 "xuexin"。
        MSG
      end
    end
  end
end
