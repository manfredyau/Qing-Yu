# 管理后台认证（独立 cookie，与用户端会话互不干扰）
module AdminAuthentication
  extend ActiveSupport::Concern

  class_methods do
    def allow_unauthenticated_admin_access(**options)
      skip_before_action :require_admin_authentication, **options
    end
  end

  private
    def require_admin_authentication
      resume_admin_session || redirect_to(new_admin_session_path)
    end

    def resume_admin_session
      Current.admin_session ||= Session.find_by(id: cookies.signed[:admin_session_id], sessionable_type: "AdminUser") if cookies.signed[:admin_session_id]
    end

    def start_admin_session_for(admin_user)
      admin_user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.admin_session = session
        cookies.signed.permanent[:admin_session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_admin_session
      Current.admin_session&.destroy
      cookies.delete(:admin_session_id)
    end
end
