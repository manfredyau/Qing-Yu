module Admin
  class PhotosController < BaseController
    def index
      @photos = Photo.order(created_at: :desc)
      @photos = @photos.where(status: params[:status]) if params[:status].present?
      @photos = @photos.includes(:user).limit(100)
    end

    def approve
      @photo = Photo.find(params[:id])
      @photo.update!(status: :approved, reviewer: admin_user, reviewed_at: Time.current, rejection_reason: nil)
      # 若用户还没有头像，将首张通过的照片设为主图
      unless @photo.user.photos.approved.primary.exists?
        @photo.update!(primary: true)
      end
      redirect_to admin_photos_path, notice: "照片已通过审核"
    end

    def reject
      @photo = Photo.find(params[:id])
      @photo.update!(status: :rejected, reviewer: admin_user, reviewed_at: Time.current, rejection_reason: params[:reason].presence || "照片不符合规范")
      redirect_to admin_photos_path, notice: "照片已驳回"
    end
  end
end
