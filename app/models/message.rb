class Message < ApplicationRecord
  belongs_to :match
  belongs_to :sender, class_name: "User"

  validates :body, presence: true, length: { maximum: 500 }

  after_create_commit :broadcast_and_touch

  private
    # 实时广播给聊天室双方（Turbo Stream），并更新匹配列表排序时间
    def broadcast_and_touch
      match.touch(:last_message_at)

      broadcast_prepend_to [ match, :messages ],
        target: "match_messages",
        partial: "messages/message",
        locals: { message: self }
    end
end
