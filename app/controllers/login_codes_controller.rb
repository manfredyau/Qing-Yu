class LoginCodesController < ApplicationController
  allow_unauthenticated_access only: :create
  rate_limit to: 3, within: 1.minute, only: :create,
    with: -> { redirect_to new_session_path, alert: "获取验证码过于频繁，请稍后再试。" }

  def create
    @phone = params[:phone].to_s.strip

    if SmsCode.new(phone: @phone, purpose: :login).valid?
      plaintext, = SmsCode.issue_for_login(@phone)
      MockSmsService.send_login_code(@phone, plaintext)

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("login-card", partial: "sessions/login_card") }
        format.html { redirect_to new_session_path(phone: @phone), notice: "验证码已发送，请注意查收。" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("login-card", partial: "sessions/login_card") }
        format.html { redirect_to new_session_path, alert: "请输入正确的手机号。" }
      end
    end
  end
end
