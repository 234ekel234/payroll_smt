require "test_helper"

class DailyTimeRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @daily_time_record = daily_time_records(:one)
  end

  test "should get index" do
    get daily_time_records_url
    assert_response :success
  end

  test "should get new" do
    get new_daily_time_record_url
    assert_response :success
  end

  test "should create daily_time_record" do
    assert_difference("DailyTimeRecord.count") do
      post daily_time_records_url, params: { daily_time_record: { abnormal_situation: @daily_time_record.abnormal_situation, clock_in: @daily_time_record.clock_in, clock_out: @daily_time_record.clock_out, date: @daily_time_record.date, employee_id: @daily_time_record.employee_id, night_diff_minutes: @daily_time_record.night_diff_minutes, overtime_minutes: @daily_time_record.overtime_minutes } }
    end

    assert_redirected_to daily_time_record_url(DailyTimeRecord.last)
  end

  test "should show daily_time_record" do
    get daily_time_record_url(@daily_time_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_daily_time_record_url(@daily_time_record)
    assert_response :success
  end

  test "should update daily_time_record" do
    patch daily_time_record_url(@daily_time_record), params: { daily_time_record: { abnormal_situation: @daily_time_record.abnormal_situation, clock_in: @daily_time_record.clock_in, clock_out: @daily_time_record.clock_out, date: @daily_time_record.date, employee_id: @daily_time_record.employee_id, night_diff_minutes: @daily_time_record.night_diff_minutes, overtime_minutes: @daily_time_record.overtime_minutes } }
    assert_redirected_to daily_time_record_url(@daily_time_record)
  end

  test "should destroy daily_time_record" do
    assert_difference("DailyTimeRecord.count", -1) do
      delete daily_time_record_url(@daily_time_record)
    end

    assert_redirected_to daily_time_records_url
  end
end
