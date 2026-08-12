class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_session_path, alert: "尝试过于频繁，请稍后再试。" }

  def new
    # 已登录用户访问登录页（如多 Tab 残留的旧页面）直接回首页
    redirect_to(root_path) if authenticated?

    @phone = params[:phone]
  end

  def create
    @phone = params[:phone].to_s.strip
    sms_code = SmsCode.unconsumed.where(phone: @phone, purpose: :login)
                      .order(expires_at: :desc).first

    if sms_code&.valid_code?(params[:code].to_s.strip)
      sms_code.consume!
      user = User.find_or_create_by!(phone: @phone) { |u| u.nickname = "轻友#{@phone.last(4)}" }
      start_new_session_for user
      redirect_to after_authentication_url
    else
      sms_code&.record_attempt!
      redirect_to new_session_path(phone: @phone), alert: "验证码错误或已过期，请重新获取。"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
