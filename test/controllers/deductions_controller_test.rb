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
      post deductions_url, params: { deduction: {} }
    end

    assert_redirected_to deduction_url(Deduction.last)
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
    patch deduction_url(@deduction), params: { deduction: {} }
    assert_redirected_to deduction_url(@deduction)
  end

  test "should destroy deduction" do
    assert_difference("Deduction.count", -1) do
      delete deduction_url(@deduction)
    end

    assert_redirected_to deductions_url
  end
end
