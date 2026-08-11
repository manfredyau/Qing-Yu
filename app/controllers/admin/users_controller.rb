module Admin
  class UsersController < BaseController
    def index
      @users = User.order(created_at: :desc)
      @users = @users.where(verification_level: params[:verification_level]) if params[:verification_level].present?
      @users = @users.limit(100)
    end

    def show
      @user = User.find(params[:id])
    end

    def suspend
      @user = User.find(params[:id])
      @user.update!(status: :suspended)
      redirect_to admin_user_path(@user), notice: "已封禁 #{@user.display_name}"
    end

    def unsuspend
      @user = User.find(params[:id])
      @user.update!(status: :active)
      redirect_to admin_user_path(@user), notice: "已解封 #{@user.display_name}"
    end
  end
end
