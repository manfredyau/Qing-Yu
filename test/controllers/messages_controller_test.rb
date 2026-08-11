require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @zoe = users(:one)
    @jack = users(:two)
    @match = MatcherService.create_match(@zoe, @jack)
    sign_in_as(@zoe)
  end

  test "participant can send a message" do
    assert_difference("Message.count", 1) do
      post match_messages_path(@match), params: { message: { body: "你好" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert @match.reload.last_message_at.present?
  end

  test "non-participant cannot send a message" do
    outsider = User.create!(phone: "13900000000")
    sign_in_as(outsider)

    assert_no_difference("Message.count") do
      post match_messages_path(@match), params: { message: { body: "hack" } }
    end
    assert_response :not_found
  end

  test "opening a chat room marks it read" do
    Message.create!(match: @match, sender: @jack, body: "hi")

    get match_path(@match)

    assert_response :success
    assert_equal 0, @match.unread_count_for(@zoe)
  end
end
