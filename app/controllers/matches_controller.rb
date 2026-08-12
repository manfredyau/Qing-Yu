class MatchesController < ApplicationController
  # 消息列表缓存 60 秒（未读数/新消息变化快）；聊天室实时内容不缓存
  def page_cache_ttl
    action_name == "index" ? 60 : nil
  end

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
