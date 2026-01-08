require "test_helper"

class PayrollsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payroll = payrolls(:one)
  end

  test "should get index" do
    get payrolls_url
    assert_response :success
  end

  test "should get new" do
    get new_payroll_url
    assert_response :success
  end

  test "should create payroll" do
    assert_difference("Payroll.count") do
      post payrolls_url, params: { payroll: { allowance: @payroll.allowance, basic_pay: @payroll.basic_pay, daily_rate: @payroll.daily_rate, days_worked: @payroll.days_worked, employee_id: @payroll.employee_id, end_date: @payroll.end_date, gross_pay: @payroll.gross_pay, holiday_pay: @payroll.holiday_pay, net_pay: @payroll.net_pay, night_diff_pay: @payroll.night_diff_pay, overtime_pay: @payroll.overtime_pay, processed_at: @payroll.processed_at, rest_day_pay: @payroll.rest_day_pay, start_date: @payroll.start_date, status: @payroll.status, total_deductions: @payroll.total_deductions } }
    end

    assert_redirected_to payroll_url(Payroll.last)
  end

  test "should show payroll" do
    get payroll_url(@payroll)
    assert_response :success
  end

  test "should get edit" do
    get edit_payroll_url(@payroll)
    assert_response :success
  end

  test "should update payroll" do
    patch payroll_url(@payroll), params: { payroll: { allowance: @payroll.allowance, basic_pay: @payroll.basic_pay, daily_rate: @payroll.daily_rate, days_worked: @payroll.days_worked, employee_id: @payroll.employee_id, end_date: @payroll.end_date, gross_pay: @payroll.gross_pay, holiday_pay: @payroll.holiday_pay, net_pay: @payroll.net_pay, night_diff_pay: @payroll.night_diff_pay, overtime_pay: @payroll.overtime_pay, processed_at: @payroll.processed_at, rest_day_pay: @payroll.rest_day_pay, start_date: @payroll.start_date, status: @payroll.status, total_deductions: @payroll.total_deductions } }
    assert_redirected_to payroll_url(@payroll)
  end

  test "should destroy payroll" do
    assert_difference("Payroll.count", -1) do
      delete payroll_url(@payroll)
    end

    assert_redirected_to payrolls_url
  end
end
