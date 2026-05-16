require "test_helper"

class PayMultipliersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pay_multiplier = pay_multipliers(:regular)
  end

  test "should get index" do
    get pay_multipliers_url
    assert_response :success
  end

  test "should get new" do
    get new_pay_multiplier_url
    assert_response :success
  end

  test "should create pay_multiplier" do
    assert_difference("PayMultiplier.count") do
      post pay_multipliers_url, params: { pay_multiplier: { base_multiplier: @pay_multiplier.base_multiplier, code: @pay_multiplier.code, holiday_type: @pay_multiplier.holiday_type, name: @pay_multiplier.name, overtime: @pay_multiplier.overtime, rest_day: @pay_multiplier.rest_day } }
    end

    assert_redirected_to pay_multiplier_url(PayMultiplier.last)
  end

  test "should show pay_multiplier" do
    get pay_multiplier_url(@pay_multiplier)
    assert_response :success
  end

  test "should get edit" do
    get edit_pay_multiplier_url(@pay_multiplier)
    assert_response :success
  end

  test "should update pay_multiplier" do
    patch pay_multiplier_url(@pay_multiplier), params: { pay_multiplier: { base_multiplier: @pay_multiplier.base_multiplier, code: @pay_multiplier.code, holiday_type: @pay_multiplier.holiday_type, name: @pay_multiplier.name, overtime: @pay_multiplier.overtime, rest_day: @pay_multiplier.rest_day } }
    assert_redirected_to pay_multiplier_url(@pay_multiplier)
  end

  test "should destroy pay_multiplier" do
    assert_difference("PayMultiplier.count", -1) do
      delete pay_multiplier_url(@pay_multiplier)
    end

    assert_redirected_to pay_multipliers_url
  end
end
