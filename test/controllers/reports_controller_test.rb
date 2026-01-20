require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get attendance" do
    get reports_attendance_url
    assert_response :success
  end
end
