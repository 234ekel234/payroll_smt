require "test_helper"

class GovDeductionBracketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gov_deduction_bracket = gov_deduction_brackets(:one)
  end

  test "should get index" do
    get gov_deduction_brackets_url
    assert_response :success
  end

  test "should get new" do
    get new_gov_deduction_bracket_url
    assert_response :success
  end

  test "should create gov_deduction_bracket" do
    assert_difference("GovDeductionBracket.count") do
      post gov_deduction_brackets_url, params: { gov_deduction_bracket: { amount: @gov_deduction_bracket.amount, deduction_type: @gov_deduction_bracket.deduction_type, range_max: @gov_deduction_bracket.range_max, range_min: @gov_deduction_bracket.range_min } }
    end

    assert_redirected_to gov_deduction_bracket_url(GovDeductionBracket.last)
  end

  test "should show gov_deduction_bracket" do
    get gov_deduction_bracket_url(@gov_deduction_bracket)
    assert_response :success
  end

  test "should get edit" do
    get edit_gov_deduction_bracket_url(@gov_deduction_bracket)
    assert_response :success
  end

  test "should update gov_deduction_bracket" do
    patch gov_deduction_bracket_url(@gov_deduction_bracket), params: { gov_deduction_bracket: { amount: @gov_deduction_bracket.amount, deduction_type: @gov_deduction_bracket.deduction_type, range_max: @gov_deduction_bracket.range_max, range_min: @gov_deduction_bracket.range_min } }
    assert_redirected_to gov_deduction_bracket_url(@gov_deduction_bracket)
  end

  test "should destroy gov_deduction_bracket" do
    assert_difference("GovDeductionBracket.count", -1) do
      delete gov_deduction_bracket_url(@gov_deduction_bracket)
    end

    assert_redirected_to gov_deduction_brackets_url
  end
end
