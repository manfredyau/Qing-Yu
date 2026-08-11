class MatchesController < ApplicationController
  def index
    @matches = current_user.matches.active.recent
  end

  def show
    @match = current_user.matches.active.find(params[:id])
    @messages = @match.messages.order(:created_at).includes(:sender)
    # 打开聊天室即标记已读
    @match.membership_for(current_user)&.update!(last_read_at: Time.current)
  end
end
