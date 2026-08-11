require "test_helper"

class VerificationServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @valid_id = "11010519491231002X"
  end

  test "id card verification succeeds and upgrades user to V1" do
    record = Verification::IdCardVerificationService.new(@user)
      .verify(full_name: "张三", id_number: @valid_id)

    assert record.verified?
    assert_equal "id_verified", @user.reload.verification_level
    assert @user.verified?
  end

  test "id card verification rejects mock blacklist names" do
    record = Verification::IdCardVerificationService.new(@user)
      .verify(full_name: "李四", id_number: @valid_id)

    assert record.rejected?
    assert_equal "unverified", @user.reload.verification_level
    assert record.rejection_reason.present?
  end

  test "id card verification returns errors for invalid input" do
    record = Verification::IdCardVerificationService.new(@user)
      .verify(full_name: "", id_number: "bad")

    assert record.errors.any?
    assert_equal "unverified", @user.reload.verification_level
  end

  test "education verification succeeds and upgrades user to V2 when identity verified" do
    Verification::IdCardVerificationService.new(@user)
      .verify(full_name: "张三", id_number: @valid_id)

    record = Verification::EducationVerificationService.new(@user)
      .verify(verify_code: "100000000001", report_no: "ABCDEF1234567890")

    assert record.verified?
    assert_equal "北京大学", record.school
    assert_equal "fully_verified", @user.reload.verification_level
  end

  test "education verification with unknown code is rejected" do
    record = Verification::EducationVerificationService.new(@user)
      .verify(verify_code: "999999999999", report_no: "ABCDEF1234567890")

    assert record.rejected?
    assert_match(/未查询到学籍信息/, record.rejection_reason)
  end

  test "education verification validates code and report format" do
    record = Verification::EducationVerificationService.new(@user)
      .verify(verify_code: "123", report_no: "short")

    assert record.errors.any?
  end

  test "provider factory raises on unknown provider" do
    assert_raises(ArgumentError) { Verification::IdCardProvider.for("nobody") }
    assert_raises(ArgumentError) { Verification::EducationProvider.for("nobody") }
  end
end
