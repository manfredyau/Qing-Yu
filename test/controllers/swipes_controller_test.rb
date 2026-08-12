require "test_helper"

class SwipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @zoe = users(:one)
    @jack = users(:two)
    @jack.update!(verification_level: :id_verified, birthdate: 25.years.ago)
    @zoe.update!(verification_level: :id_verified, birthdate: 25.years.ago, pref_gender: :male)
    sign_in_as(@zoe)
  end

  test "like without match renders turbo stream with next card" do
    assert_difference("Swipe.count", 1) do
      post swipes_path, params: { target_id: @jack.id, decision: "like" },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "mutual like creates a match" do
    Swipe.create!(liker: @jack, target: @zoe, action: :like)

    assert_difference("Match.count", 1) do
      post swipes_path, params: { target_id: @jack.id, decision: "like" }
    end
  end

  test "pass records a swipe" do
    assert_difference("Swipe.count", 1) do
      post swipes_path, params: { target_id: @jack.id, decision: "pass" }
    end
    assert @zoe.swipes.exists?(target: @jack, action: :pass)
  end

  test "unknown decision is ignored" do
    assert_no_difference("Swipe.count") do
      post swipes_path, params: { target_id: @jack.id, decision: "whatever" }
    end
  end

  test "swiping consumes the candidate from today's recommendation queue" do
    service = RecommendationService.new(@zoe)
    assert_includes service.queue, @jack.id

    post swipes_path, params: { target_id: @jack.id, decision: "pass" },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success

    assert_not_includes RecommendationService.new(@zoe).queue, @jack.id
  end

  test "unknown decision does not consume the queue" do
    service = RecommendationService.new(@zoe)
    assert_includes service.queue, @jack.id

    post swipes_path, params: { target_id: @jack.id, decision: "whatever" }

    assert_includes RecommendationService.new(@zoe).queue, @jack.id
  end
end
