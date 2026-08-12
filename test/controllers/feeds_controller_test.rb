require "test_helper"

class FeedsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @zoe = users(:one)
    @jack = users(:two)
    @jack.update!(verification_level: :id_verified, birthdate: 25.years.ago, gender: :male, pref_gender: :female)
    @zoe.update!(verification_level: :id_verified, birthdate: 25.years.ago, pref_gender: :male)
    sign_in_as(@zoe)
  end

  test "unverified user sees onboarding without redirect" do
    @zoe.update!(verification_level: :unverified)

    get feed_path

    assert_response :success
    assert_match(/完成实名认证，开启轻遇之旅/, response.body)
  end

  test "incomplete profile sees onboarding without redirect" do
    get feed_path

    assert_response :success
    assert_match(/完善资料，让推荐更精准/, response.body)
    # 明确列出缺什么，而不是泛泛的"还差照片、兴趣标签等资料"
    assert_match(/还差：/, response.body)
    assert_match(/兴趣标签/, response.body)
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

  test "feed is conditionally cached with ETag (304 on revalidation)" do
    make_profile_complete(@zoe)

    get feed_path
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?
    assert_match(/private/, response.headers["Cache-Control"])

    get feed_path, headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end

  test "feed ETag changes after a swipe consumes the daily queue" do
    make_profile_complete(@zoe)

    get feed_path
    etag_before = response.headers["ETag"]

    post swipes_path, params: { target_id: @jack.id, decision: "pass" },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success

    get feed_path
    assert_response :success
    assert_not_equal etag_before, response.headers["ETag"]
  end

  test "candidate with only a pending photo shows under-review badge on card" do
    make_profile_complete(@zoe)
    @jack.update!(nickname: "小杰", city: "上海", interest_ids: [ interests(:one).id ])
    @jack.photos.create!(file: { io: StringIO.new("img"), filename: "p.png", content_type: "image/png" }, status: :pending)

    get feed_path
    assert_response :success
    assert_match(/照片审核中/, response.body)
  end

  private
    def make_profile_complete(user)
      user.update!(nickname: "小轻", city: "北京", interest_ids: [ interests(:one).id ])
      user.photos.create!(file: { io: StringIO.new("img"), filename: "p.png", content_type: "image/png" }, status: :approved)
    end
end
