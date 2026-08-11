module Verification
  # 身份证核验服务商抽象层
  # 通过 config.x.verification.id_card_provider 选择实现（默认 mock）
  module IdCardProvider
    Result = Verification::Result

    def self.for(name)
      case name.to_s
      when "mock"     then IdCard::MockProvider.new
      when "aliyun"   then IdCard::AliyunProvider.new
      when "tencent"  then IdCard::TencentProvider.new
      else raise ArgumentError, "未知的身份证核验服务商: #{name}"
      end
    end
  end
end
