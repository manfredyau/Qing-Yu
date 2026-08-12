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

  test "saving incomplete profile alerts exactly what is missing" do
    patch profile_path, params: {
      user: { nickname: "小轻", gender: "female", birthdate: 25.years.ago.to_date.to_s, city: "北京" }
    }

    assert_redirected_to edit_profile_path
    assert_equal "资料已保存，还差：照片、兴趣标签", flash[:alert]
  end

  test "validation errors render all messages on the form" do
    patch profile_path, params: {
      user: { nickname: "小轻", gender: "female", birthdate: "2012-01-01", city: "北京" }
    }

    assert_response :unprocessable_entity
    assert_match(/保存失败，请修正/, response.body)
    assert_match(/必须年满 18 周岁/, response.body)
  end

  test "saving a complete profile redirects with notice" do
    @zoe.update!(nickname: "小轻", gender: :female, birthdate: 25.years.ago, city: "北京")
    @zoe.photos.create!(file: { io: StringIO.new("img"), filename: "p.png", content_type: "image/png" }, status: :approved)

    patch profile_path, params: {
      user: { nickname: "小轻", gender: "female", birthdate: 25.years.ago.to_date.to_s, city: "北京", interest_ids: [ interests(:one).id ] }
    }

    assert_redirected_to edit_profile_path
    assert_equal "资料已保存", flash[:notice]
  end

  test "pending photo still completes the profile (moderation does not block)" do
    @zoe.photos.create!(file: { io: StringIO.new("img"), filename: "p.png", content_type: "image/png" }, status: :pending)

    patch profile_path, params: {
      user: { nickname: "小轻", gender: "female", birthdate: 25.years.ago.to_date.to_s, city: "北京", interest_ids: [ interests(:one).id ] }
    }

    assert_redirected_to edit_profile_path
    assert_equal "资料已保存", flash[:notice]
  end
end
