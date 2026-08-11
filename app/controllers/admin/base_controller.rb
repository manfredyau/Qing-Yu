module Admin
  class BaseController < ApplicationController
    include AdminAuthentication

    skip_before_action :require_authentication
    before_action :require_admin_authentication

    layout "admin"

    helper_method :admin_user

    private
      def admin_user
        Current.admin_user
      end
  end
end
