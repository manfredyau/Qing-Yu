require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes phone by stripping whitespace" do
    user = User.new(phone: " 138 0000 0001 ")
    assert_equal "13800000001", user.phone
  end

  test "rejects invalid phone" do
    user = User.new(phone: "12345")
    assert_not user.valid?
    assert_includes user.errors[:phone], "请输入正确的手机号"
  end

  test "rejects underage users" do
    user = User.new(phone: "13800000003", birthdate: 17.years.ago)
    assert_not user.valid?
    assert_includes user.errors[:birthdate], "必须年满 18 周岁"
  end

  test "accepts adult users" do
    user = User.new(phone: "13800000003", birthdate: 25.years.ago)
    assert user.valid?
  end

  test "computed age" do
    user = users(:one)
    user.update!(birthdate: 25.years.ago.to_date)
    assert_equal 25, user.age
  end

  test "verification state helpers" do
    user = users(:one)
    assert_not user.verified?

    user.update!(verification_level: :id_verified)
    assert user.verified?
    assert_not user.fully_verified?
  end

  test "searchable scope requires active + verified + disclosed gender" do
    user = users(:one)
    user.update!(verification_level: :id_verified)
    assert_includes User.searchable, user

    user.update!(gender: :undisclosed)
    assert_not_includes User.searchable, user
  end
end
