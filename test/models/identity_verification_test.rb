require "test_helper"

class IdentityVerificationTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @valid_id = "11010519491231002X"
  end

  test "encrypts id_number and decrypts transparently" do
    record = IdentityVerification.create!(user: @user, full_name: "张三", id_number: @valid_id)
    raw = ActiveRecord::Base.connection.select_value(
      ActiveRecord::Base.sanitize_sql_array([ "SELECT id_number FROM identity_verifications WHERE id = ?", record.id ])
    )
    assert_not_equal @valid_id, raw
    assert_equal @valid_id, record.reload.id_number
  end

  test "rejects invalid id number format" do
    record = IdentityVerification.new(user: @user, full_name: "张三", id_number: "123")
    assert_not record.valid?
    assert_includes record.errors[:id_number], "身份证号格式不正确"
  end

  test "requires full name" do
    record = IdentityVerification.new(user: @user, full_name: "", id_number: @valid_id)
    assert_not record.valid?
  end

  test "masks id number for display" do
    record = IdentityVerification.new(user: @user, full_name: "张三", id_number: @valid_id)
    assert_equal "1101**********002X", record.masked_id_number
  end
end
