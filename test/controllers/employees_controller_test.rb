require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:one)
  end

  test "should get index" do
    get employees_url
    assert_response :success
  end

  test "should get new" do
    get new_employee_url
    assert_response :success
  end

  test "should create employee" do
    assert_difference("Employee.count") do
      post employees_url, params: { employee: { allowance_per_day: @employee.allowance_per_day, basic_rate: @employee.basic_rate, break_end: @employee.break_end, break_start: @employee.break_start, company: @employee.company, landbank_atm: @employee.landbank_atm, name: @employee.name, person_id: @employee.person_id, schedule: @employee.schedule, shift_end: @employee.shift_end, shift_start: @employee.shift_start, status_of_employment: @employee.status_of_employment } }
    end

    assert_redirected_to employee_url(Employee.last)
  end

  test "should show employee" do
    get employee_url(@employee)
    assert_response :success
  end

  test "should get edit" do
    get edit_employee_url(@employee)
    assert_response :success
  end

  test "should update employee" do
    patch employee_url(@employee), params: { employee: { allowance_per_day: @employee.allowance_per_day, basic_rate: @employee.basic_rate, break_end: @employee.break_end, break_start: @employee.break_start, company: @employee.company, landbank_atm: @employee.landbank_atm, name: @employee.name, person_id: @employee.person_id, schedule: @employee.schedule, shift_end: @employee.shift_end, shift_start: @employee.shift_start, status_of_employment: @employee.status_of_employment } }
    assert_redirected_to employee_url(@employee)
  end

  test "should destroy employee" do
    assert_difference("Employee.count", -1) do
      delete employee_url(@employee)
    end

    assert_redirected_to employees_url
  end
end
