require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "requires a file attachment" do
    photo = Photo.new(user: @user)
    assert_not photo.valid?
    assert_includes photo.errors[:file], "请选择图片文件"
  end

  test "rejects non-image content type" do
    photo = Photo.new(user: @user)
    photo.file.attach(io: StringIO.new("hello"), filename: "x.txt", content_type: "text/plain")
    assert_not photo.valid?
    assert_includes photo.errors[:file], "仅支持 JPG / PNG / WebP 格式"
  end

  test "accepts a valid image" do
    photo = Photo.new(user: @user)
    photo.file.attach(io: StringIO.new("fakeimage"), filename: "x.png", content_type: "image/png")
    assert photo.valid?
  end

  test "only one primary photo per user" do
    first = @user.photos.create!(file: { io: StringIO.new("a"), filename: "a.png", content_type: "image/png" }, status: :approved, primary: true)
    second = @user.photos.create!(file: { io: StringIO.new("b"), filename: "b.png", content_type: "image/png" }, status: :approved, primary: true)

    assert second.primary?
    assert_not first.reload.primary?
  end

  test "reassigns primary when primary photo destroyed" do
    first = @user.photos.create!(file: { io: StringIO.new("a"), filename: "a.png", content_type: "image/png" }, status: :approved, primary: true)
    second = @user.photos.create!(file: { io: StringIO.new("b"), filename: "b.png", content_type: "image/png" }, status: :approved)

    first.destroy

    assert second.reload.primary?
  end
end
