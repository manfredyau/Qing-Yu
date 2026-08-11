class FeedsController < ApplicationController
  def show
    return redirect_to verification_path, alert: "完成实名认证后，才会出现在推荐中" unless current_user.verified?
    return redirect_to edit_profile_path, alert: "请先完善资料（昵称/照片/标签等），再开始推荐" unless current_user.profile_complete?

    @service = RecommendationService.new(current_user)
    @candidate = @service.exhausted? ? nil : @service.next_candidate
    @remaining = @service.remaining_today
  end
end
