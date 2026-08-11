# 短信发送服务（Mock）
#
# 开发环境将验证码写入日志；生产环境接入真实短信服务商（阿里云/腾讯云短信）后
# 替换本类实现，接口保持不变。
class MockSmsService
  class << self
    # 仅限开发/测试环境使用；生产环境应返回发送结果（成功/失败）
    def send_login_code(phone, plaintext_code)
      Rails.logger.info("[MOCK-SMS] 登录验证码 #{plaintext_code} 已发送至 #{phone}（#{SmsCode::LOGIN_TTL.to_i / 60} 分钟内有效）")
      true
    end
  end
end
