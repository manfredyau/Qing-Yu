require "test_helper"

class UserProfileTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "profile is incomplete without required fields" do
    assert_not @user.profile_complete?
  end

  test "profile is complete with all required fields" do
    @user.update!(
      nickname: "小轻", gender: :female, birthdate: 25.years.ago,
      city: "北京", interest_ids: [ interests(:one).id ]
    )
    @user.photos.create!(file: { io: StringIO.new("img"), filename: "p.png", content_type: "image/png" }, status: :approved)

    assert @user.profile_complete?
  end

  test "missing_profile_parts lists exactly what is missing" do
    # fixture users(:one) 已有昵称和性别
    assert_equal %w[生日 城市 照片 兴趣标签], @user.missing_profile_parts

    @user.update!(birthdate: 25.years.ago, city: "北京")

    assert_equal %w[照片 兴趣标签], @user.missing_profile_parts
  end

  test "pending photos count toward profile completion and avatar" do
    @user.update!(birthdate: 25.years.ago, city: "北京", interest_ids: [ interests(:one).id ])
    photo = @user.photos.create!(file: { io: StringIO.new("img"), filename: "p.png", content_type: "image/png" }, status: :pending)

    # 照片审核不阻塞用户自己的资料完成；审核结果只影响他人可见性（视图标注「审核中」）
    assert @user.profile_complete?
    assert_not_includes @user.missing_profile_parts, "照片"
    assert_equal photo, @user.avatar_photo
  end

  test "avatar_photo falls back to pending photo so the upload is visible" do
    pending = @user.photos.create!(file: { io: StringIO.new("p"), filename: "p.png", content_type: "image/png" }, status: :pending)

    assert_equal pending, @user.avatar_photo
  end

  test "avatar_photo returns primary approved photo" do
    primary = @user.photos.create!(file: { io: StringIO.new("a"), filename: "a.png", content_type: "image/png" }, status: :approved, primary: true)
    @user.photos.create!(file: { io: StringIO.new("b"), filename: "b.png", content_type: "image/png" }, status: :pending)

    assert_equal primary, @user.avatar_photo
  end

  test "avatar_photo falls back to first approved photo" do
    approved = @user.photos.create!(file: { io: StringIO.new("a"), filename: "a.png", content_type: "image/png" }, status: :approved)

    assert_equal approved, @user.avatar_photo
  end

  test "has_avatar? reflects presence" do
    assert_not @user.has_avatar?
    @user.photos.create!(file: { io: StringIO.new("a"), filename: "a.png", content_type: "image/png" }, status: :approved)
    assert @user.has_avatar?
  end

  test "education level labels" do
    assert_equal "本科", User.education_level_label("bachelor")
    assert_equal "硕士", User.education_level_label(:master)
    assert_equal "不填", User.education_level_label("not_disclosed")
  end
end
