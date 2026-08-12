require "test_helper"

class HotwireNativeControllerTest < ActionDispatch::IntegrationTest
  test "ios path configuration returns JSON rules" do
    get hotwire_native_v1_ios_path_configuration_path
    assert_response :success
    json = JSON.parse(response.body)
    assert json["rules"].is_a?(Array)
    assert json["rules"].any? { |r| r["patterns"].any? { |p| p.include?("session/new") } }
  end

  test "android path configuration returns JSON rules" do
    get hotwire_native_v1_android_path_configuration_path
    assert_response :success
    json = JSON.parse(response.body)
    assert json["rules"].is_a?(Array)
  end

  test "native tabs redirect to app pages" do
    sign_in_as(users(:one))

    get hotwire_native_tab1_path
    assert_redirected_to %r{/feed}

    get hotwire_native_tab2_path
    assert_redirected_to %r{/matches}

    get hotwire_native_tab3_path
    assert_redirected_to %r{/profile}
  end

  test "native user agent marks the page as native" do
    sign_in_as(users(:one))

    get profile_path, headers: { "User-Agent" => "Turbo Native iOS 1.0" }

    assert_response :success
    assert_match(/data-hotwire-native/, response.body)
  end
end
