require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @phone = "13800000001"
    @user = users(:one)
  end

  test "new renders the login page" do
    get new_session_path
    assert_response :success
    assert_select "turbo-frame#login-card"
  end

  test "create with valid code signs in an existing phone" do
    code, = SmsCode.issue_for_login(@phone)
    SmsCode.last.update!(code_digest: Digest::SHA256.hexdigest(code))

    assert_difference("User.count", 0) do
      post session_path, params: { phone: @phone, code: code }
    end
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with valid code registers a brand-new phone" do
    phone = "13900000000"
    code, = SmsCode.issue_for_login(phone)

    assert_difference("User.count", 1) do
      post session_path, params: { phone: phone, code: code }
    end
    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with wrong code is rejected" do
    code, = SmsCode.issue_for_login(@phone)
    SmsCode.last.update!(code_digest: Digest::SHA256.hexdigest(code))

    post session_path, params: { phone: @phone, code: "000000" }

    assert_redirected_to new_session_path(phone: @phone)
    assert_nil cookies[:session_id]
  end

  test "create with expired code is rejected" do
    expired = sms_codes(:expired)
    post session_path, params: { phone: expired.phone, code: "654321" }
    assert_redirected_to new_session_path(phone: expired.phone)
    assert_nil cookies[:session_id]
  end

  test "destroy signs out" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
