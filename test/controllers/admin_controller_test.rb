require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admin_users(:admin)
  end

  test "admin dashboard requires authentication" do
    get admin_root_path
    assert_redirected_to new_admin_session_path
  end

  test "admin login with valid credentials" do
    post admin_session_path, params: { email_address: @admin.email_address, password: "password123" }
    assert_redirected_to admin_root_path
    assert cookies[:admin_session_id]
  end

  test "admin login with wrong password" do
    post admin_session_path, params: { email_address: @admin.email_address, password: "wrong" }
    assert_redirected_to new_admin_session_path
    assert_nil cookies[:admin_session_id]
  end

  test "admin can view dashboard and queues" do
    sign_in_admin

    get admin_root_path
    assert_response :success

    get admin_identity_verifications_path
    assert_response :success

    get admin_users_path
    assert_response :success
  end

  test "admin approves identity verification and syncs user level" do
    user = users(:one)
    verification = Verification::IdCardVerificationService.new(user)
      .verify(full_name: "张三", id_number: "11010519491231002X")
    user.update!(verification_level: :unverified, verified_at: nil)
    sign_in_admin

    patch approve_admin_identity_verification_path(verification)

    assert_redirected_to admin_identity_verifications_path
    assert_equal "id_verified", user.reload.verification_level
  end

  test "admin approves photo" do
    user = users(:one)
    photo = user.photos.create!(file: { io: StringIO.new("img"), filename: "p.png", content_type: "image/png" })
    sign_in_admin

    patch approve_admin_photo_path(photo)

    assert photo.reload.approved?
  end

  test "admin suspends and unsuspends a user" do
    user = users(:one)
    sign_in_admin

    patch suspend_admin_user_path(user)
    assert user.reload.suspended?

    patch unsuspend_admin_user_path(user)
    assert user.reload.active?
  end

  private
    def sign_in_admin
      post admin_session_path, params: { email_address: @admin.email_address, password: "password123" }
    end
end
