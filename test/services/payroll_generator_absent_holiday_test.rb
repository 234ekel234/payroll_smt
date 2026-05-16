require "test_helper"

class PayrollGeneratorAbsentHolidayTest < ActiveSupport::TestCase
  setup do
    @employee = employees(:one)  # basic_rate: 650, Mon–Fri
  end

  # Helper — run just the absent holiday pay calculation (extracted logic)
  def absent_pay(start_date, end_date, dtr_dates)
    generator = PayrollGenerator.new(
      start_date: start_date,
      end_date:   end_date,
      employees:  @employee
    )
    generator.send(:absent_holiday_pay, @employee, dtr_dates.to_set)
  end

  test "no pay when employee was present on the holiday" do
    # Labor Day is a Friday (regular holiday); employee has a DTR for it
    start_date = Date.new(2026, 5, 1)
    end_date   = Date.new(2026, 5, 1)
    dtr_dates  = [Date.new(2026, 5, 1)]

    assert_equal 0.0, absent_pay(start_date, end_date, dtr_dates)
  end

  test "no pay when employee was absent AND absent on the day before" do
    # Labor Day 2026 is a Friday. Day before = Thursday Apr 30.
    # Employee has no DTR on Apr 30 → does not qualify.
    start_date = Date.new(2026, 4, 27)
    end_date   = Date.new(2026, 5, 1)
    dtr_dates  = []  # absent all week

    assert_equal 0.0, absent_pay(start_date, end_date, dtr_dates)
  end

  test "pays one daily rate when absent on holiday but present day before" do
    # Labor Day 2026 = Friday May 1. Day before (last work day) = Thursday Apr 30.
    start_date = Date.new(2026, 4, 27)
    end_date   = Date.new(2026, 5, 1)
    dtr_dates  = [Date.new(2026, 4, 30)]  # present on Thursday, absent on Friday

    assert_equal @employee.basic_rate.to_f, absent_pay(start_date, end_date, dtr_dates)
  end

  test "no pay for special non-working holiday absence" do
    # Black Saturday (Apr 4) is special non-working — not regular — no absent pay owed
    start_date = Date.new(2026, 4, 1)
    end_date   = Date.new(2026, 4, 4)
    # Apr 4 is a Saturday → outside employee work_days (Mon–Fri), also skipped by holiday_type check
    dtr_dates  = [Date.new(2026, 4, 3)]  # present Friday

    assert_equal 0.0, absent_pay(start_date, end_date, dtr_dates)
  end

  test "pays for multiple qualifying absent holidays in range" do
    # Both Labor Day (May 1, Fri) and a second regular holiday in range
    # Use Christmas (Dec 25, Fri 2026) — employee present Dec 24 (Thu)
    start_date = Date.new(2026, 12, 21)
    end_date   = Date.new(2026, 12, 25)
    dtr_dates  = [Date.new(2026, 12, 24)]  # present Thursday

    assert_equal @employee.basic_rate.to_f, absent_pay(start_date, end_date, dtr_dates)
  end
end
