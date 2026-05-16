require "test_helper"

class PayrollTest < ActiveSupport::TestCase
  def setup
    @payroll = payrolls(:one)
  end

  test "requires start_date" do
    @payroll.start_date = nil
    assert_not @payroll.valid?
  end

  test "requires end_date" do
    @payroll.end_date = nil
    assert_not @payroll.valid?
  end

  test "requires gross_pay" do
    @payroll.gross_pay = nil
    assert_not @payroll.valid?
  end

  test "total_statutory sums sss, phic, and hdmf" do
    @payroll.sss_amount  = 581.30
    @payroll.phic_amount = 450.00
    @payroll.hdmf_amount = 200.00
    assert_in_delta 1231.30, @payroll.total_statutory, 0.01
  end

  test "calculate_final_amounts sets net_pay to gross minus deductions" do
    @payroll.gross_pay        = 15_000.00
    @payroll.sss_amount       = 581.30
    @payroll.phic_amount      = 450.00
    @payroll.hdmf_amount      = 200.00
    @payroll.sss_loan         = 0
    @payroll.hdmf_loan        = 0
    @payroll.cash_advance     = 0
    @payroll.rice_deduction   = 0
    @payroll.materials_deduction  = 0
    @payroll.groceries_deduction  = 0
    @payroll.late_ut_amount   = 0
    @payroll.save!

    @payroll.calculate_final_amounts!
    @payroll.reload

    assert_in_delta 1231.30, @payroll.total_deductions, 0.01
    assert_in_delta 13_768.70, @payroll.net_pay, 0.01
  end

  test "net_pay floors at zero" do
    @payroll.gross_pay      = 100.00
    @payroll.sss_amount     = 500.00
    @payroll.phic_amount    = 0
    @payroll.hdmf_amount    = 0
    @payroll.sss_loan = @payroll.hdmf_loan = @payroll.cash_advance = 0
    @payroll.rice_deduction = @payroll.materials_deduction = @payroll.groceries_deduction = 0
    @payroll.late_ut_amount = 0
    @payroll.save!

    @payroll.calculate_final_amounts!
    @payroll.reload

    assert_equal 0.0, @payroll.net_pay.to_f
  end
end
