class MatchesController < ApplicationController
  # 消息列表缓存版本：新消息/已读状态变化 → ETag 失效 → 返回新列表；聊天室实时内容不缓存
  def cache_version_key
    return nil if action_name == "show"

    last_message = current_user.matches.active.maximum(:last_message_at)
    last_read = MatchMembership.where(user: current_user).maximum(:last_read_at)
    "matches:#{current_user.id}:#{last_message.to_i}:#{last_read.to_i}"
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
