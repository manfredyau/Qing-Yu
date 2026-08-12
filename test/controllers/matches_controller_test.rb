require "test_helper"

class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @zoe = users(:one)
    @jack = users(:two)
    sign_in_as(@zoe)

    @match = Match.create!(user_a_id: [ @zoe.id, @jack.id ].min, user_b_id: [ @zoe.id, @jack.id ].max)
    MatchMembership.create!(match: @match, user: @zoe)
    MatchMembership.create!(match: @match, user: @jack)
  end

  test "index is conditionally cached with ETag (304 on revalidation)" do
    get matches_path
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?
    assert_match(/private/, response.headers["Cache-Control"])

    get matches_path, headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end

  test "chat room is not cached" do
    get match_path(@match)
    assert_response :success
    # 注：ActionDispatch::ETag 中间件会给所有 200 响应加 body 摘要 ETag，
    # 真正的不缓存契约是 Cache-Control: no-store（WebView 不会存储该响应）
    assert_match(/no-store/, response.headers["Cache-Control"])
  end
end
