class PhotosController < ApplicationController
  def create
    photo = current_user.photos.build(photo_params)
    if photo.save
      redirect_to edit_profile_path, notice: "照片已上传，审核通过后展示在资料中"
    else
      redirect_to edit_profile_path, alert: photo.errors.full_messages.first
    end
  end

  def destroy
    photo = current_user.photos.find(params[:id])
    photo.destroy
    redirect_to edit_profile_path, notice: "照片已删除"
  end

  def set_primary
    photo = current_user.photos.approved.find(params[:id])
    photo.update!(primary: true)
    redirect_to edit_profile_path, notice: "已设为头像"
  end

  private
    def photo_params
      params.require(:photo).permit(:file)
    end
end
