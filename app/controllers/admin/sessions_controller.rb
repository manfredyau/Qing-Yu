module Admin
  class SessionsController < BaseController
    allow_unauthenticated_admin_access only: %i[ new create ]
    rate_limit to: 10, within: 3.minutes, only: :create,
      with: -> { redirect_to new_admin_session_path, alert: "尝试过于频繁，请稍后再试。" }

    def new
    end

    def create
      if user = AdminUser.authenticate_by(email_address: params[:email_address], password: params[:password])
        start_admin_session_for user
        redirect_to admin_root_path
      else
        redirect_to new_admin_session_path, alert: "邮箱或密码错误"
      end
    end

    def destroy
      terminate_admin_session
      redirect_to new_admin_session_path, status: :see_other
    end
  end
end
