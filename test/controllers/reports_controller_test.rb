require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get attendance" do
    get attendance_report_url
    assert_response :success
  end
end
