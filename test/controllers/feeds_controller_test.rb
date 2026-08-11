require "test_helper"

class FeedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @zoe = users(:one)
    @jack = users(:two)
    @jack.update!(verification_level: :id_verified, birthdate: 25.years.ago, gender: :male, pref_gender: :female)
    @zoe.update!(verification_level: :id_verified, birthdate: 25.years.ago, pref_gender: :male)
    sign_in_as(@zoe)
  end

  test "unverified user is redirected to verification" do
    @zoe.update!(verification_level: :unverified)

    get feed_path

    assert_redirected_to verification_path
  end

  test "incomplete profile is redirected to profile edit" do
    get feed_path

    assert_redirected_to edit_profile_path
  end

  test "verified user with complete profile sees the feed" do
    make_profile_complete(@zoe)

    get feed_path

    assert_response :success
    assert_select "turbo-frame#feed-card"
  end

  test "shows pool-exhausted empty state when quota remains but no candidates left" do
    make_profile_complete(@zoe)
    # 滑完所有候选，但今日额度未用尽
    Swipe.create!(liker: @zoe, target: @jack, action: :pass)

    get feed_path

    assert_response :success
    assert_match(/今天的精选都看完了/, response.body)
    assert_no_match(/今日剩余/, response.body)
  end

  test "home redirects to feed for eligible users" do
    make_profile_complete(@zoe)

    get root_path

    assert_redirected_to feed_path
  end

  private
    def make_profile_complete(user)
      user.update!(nickname: "小轻", city: "北京", interest_ids: [ interests(:one).id ])
      user.photos.create!(file: { io: StringIO.new("img"), filename: "p.png", content_type: "image/png" }, status: :approved)
    end
end
