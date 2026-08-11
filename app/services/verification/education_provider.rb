module Verification
  # 学信网（学籍/学历）核验服务商抽象层
  # 通过 config.x.verification.education_provider 选择实现（默认 mock）
  module EducationProvider
    Result = Verification::Result

    def self.for(name)
      case name.to_s
      when "mock"   then Education::MockProvider.new
      when "aliyun" then Education::AliyunProvider.new
      when "xuexin" then Education::XuexinProvider.new
      else raise ArgumentError, "未知的学信网核验服务商: #{name}"
      end
    end
  end
end
