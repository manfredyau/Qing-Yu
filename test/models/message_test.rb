require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @zoe = users(:one)
    @jack = users(:two)
    @match = MatcherService.create_match(@zoe, @jack)
  end

  test "valid message requires body and sender" do
    message = Message.new(match: @match, sender: @zoe, body: "你好")
    assert message.valid?

    assert_not Message.new(match: @match, sender: @zoe, body: "").valid?
  end

  test "message body limited to 500 chars" do
    message = Message.new(match: @match, sender: @zoe, body: "a" * 501)
    assert_not message.valid?
  end

  test "unread count excludes own messages" do
    Message.create!(match: @match, sender: @zoe, body: "hi")
    assert_equal 0, @match.unread_count_for(@zoe)
    assert_equal 1, @match.unread_count_for(@jack)
  end

  test "unread count respects last_read_at" do
    message = Message.create!(match: @match, sender: @zoe, body: "hi")
    @match.membership_for(@jack).update!(last_read_at: message.created_at + 1.second)

    assert_equal 0, @match.unread_count_for(@jack)
  end

  test "creating message touches match last_message_at" do
    @match.update!(last_message_at: 1.hour.ago)
    Message.create!(match: @match, sender: @zoe, body: "hi")

    assert_operator @match.reload.last_message_at, :>, 1.minute.ago
  end
end
