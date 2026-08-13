require "test_helper"

class DevResetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @zoe = users(:one)
    @jack = users(:two)
    @jack.update!(verification_level: :id_verified, birthdate: 25.years.ago, gender: :male)
    @zoe.update!(verification_level: :id_verified, birthdate: 25.years.ago, pref_gender: :male)
    sign_in_as(@zoe)
  end

  test "reset recommendations clears today's swipes and the queue" do
    Swipe.create!(liker: @zoe, target: @jack, action: :pass)
    assert_equal 1, @zoe.swipes.where("created_at >= ?", Time.current.beginning_of_day).count

    post dev_reset_recommendations_path

    assert_redirected_to feed_path
    assert_equal 0, @zoe.swipes.where("created_at >= ?", Time.current.beginning_of_day).count
    # 重置后队列可重新生成（空队列不缓存 + 缓存已删除）
    assert_includes RecommendationService.new(@zoe).queue, @jack.id
  end
end
