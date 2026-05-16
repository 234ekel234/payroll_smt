require "test_helper"

class DeductionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deduction = deductions(:one)
  end

  test "should get index" do
    get deductions_url
    assert_response :success
  end

  test "should get new" do
    get new_deduction_url
    assert_response :success
  end

  test "should create deduction" do
    assert_difference("Deduction.count") do
      post deductions_url, params: { deduction: { name: "Transport Allowance", amount: 150.00, amount_type: "fixed", active: true } }
    end

    assert_redirected_to deductions_url
  end

  test "should show deduction" do
    get deduction_url(@deduction)
    assert_response :success
  end

  test "should get edit" do
    get edit_deduction_url(@deduction)
    assert_response :success
  end

  test "should update deduction" do
    patch deduction_url(@deduction), params: { deduction: { name: @deduction.name, amount: 600.00, amount_type: @deduction.amount_type } }
    assert_redirected_to deductions_url
  end

  test "should archive deduction" do
    delete deduction_url(@deduction)
    assert_redirected_to deductions_url
    assert_equal false, Deduction.find(@deduction.id).active
  end
end
