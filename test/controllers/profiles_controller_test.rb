require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @zoe = users(:one)
    sign_in_as(@zoe)
  end

  test "show is conditionally cached with ETag (304 on revalidation)" do
    get profile_path
    assert_response :success
    etag = response.headers["ETag"]
    assert etag.present?
    assert_match(/private/, response.headers["Cache-Control"])

    get profile_path, headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end

  test "edit form is not cached" do
    get edit_profile_path
    assert_response :success
    # 注：ActionDispatch::ETag 中间件会给所有 200 响应加 body 摘要 ETag，
    # 真正的不缓存契约是 Cache-Control: no-store（WebView 不会存储该响应）
    assert_match(/no-store/, response.headers["Cache-Control"])
  end
end
