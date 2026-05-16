require "test_helper"

class TimeSlicerServiceTest < ActiveSupport::TestCase
  def setup
    # Seed the multipliers needed by the service
    PayMultiplier.find_or_create_by!(code: "REGULAR")  { |m| m.name = "Regular";  m.base_multiplier = 1.0;  m.rest_day = false; m.overtime = false }
    PayMultiplier.find_or_create_by!(code: "OD-OT")    { |m| m.name = "Overtime"; m.base_multiplier = 1.25; m.rest_day = false; m.overtime = true  }
    PayMultiplier.find_or_create_by!(code: "RD")        { |m| m.name = "Rest Day"; m.base_multiplier = 1.30; m.rest_day = true;  m.overtime = false }
    PayMultiplier.find_or_create_by!(code: "RH")        { |m| m.name = "Regular Holiday"; m.base_multiplier = 2.0; m.rest_day = false; m.overtime = false }

    @employee = Employee.create!(
      name: "Test Worker",
      person_id: "TST001",
      basic_rate: 800.0,
      shift_start: "08:00:00",
      shift_end: "17:00:00",
      break_start: "12:00:00",
      break_end: "13:00:00",
      work_days: Date::DAYNAMES[1..5]
    )
  end

  def make_dtr(date:, clock_in:, clock_out:)
    # Build without callbacks so we control the slicing
    dtr = DailyTimeRecord.new(employee: @employee, date: date)
    dtr.clock_in  = Time.zone.parse("#{date} #{clock_in}")
    dtr.clock_out = Time.zone.parse("#{date} #{clock_out}")
    dtr
  end

  test "regular shift produces basic slices only" do
    dtr = make_dtr(date: "2026-05-05", clock_in: "08:00", clock_out: "17:00")
    result = TimeSlicerService.new(dtr).run

    assert result[:overtime_minutes].zero?, "expected no OT"
    assert result[:night_diff_minutes].zero?, "expected no night diff"
    assert_equal 480, result[:total_work_minutes], "8h shift minus 1h break = 480 min"
  end

  test "late arrival reduces work minutes and sets late_minutes" do
    dtr = make_dtr(date: "2026-05-05", clock_in: "08:30", clock_out: "17:00")
    result = TimeSlicerService.new(dtr).run

    assert result[:late_minutes] > 0, "expected late minutes"
    assert result[:total_work_minutes] < 480
  end

  test "grace period of 5 minutes does not count as late" do
    dtr = make_dtr(date: "2026-05-05", clock_in: "08:05", clock_out: "17:00")
    result = TimeSlicerService.new(dtr).run

    assert_equal 0, result[:late_minutes]
  end

  test "overtime requires more than 30 minutes past shift end" do
    # 30 min past — should NOT qualify
    dtr = make_dtr(date: "2026-05-05", clock_in: "08:00", clock_out: "17:30")
    result = TimeSlicerService.new(dtr).run
    assert_equal 0, result[:overtime_minutes]

    # 31 min past — should qualify
    dtr2 = make_dtr(date: "2026-05-05", clock_in: "08:00", clock_out: "17:31")
    result2 = TimeSlicerService.new(dtr2).run
    assert result2[:overtime_minutes] > 0
  end

  test "hours from 10pm to 6am are flagged as night differential" do
    dtr = make_dtr(date: "2026-05-05", clock_in: "22:00", clock_out: "23:00")
    result = TimeSlicerService.new(dtr).run

    assert result[:night_diff_minutes] > 0
  end

  test "early clock-in is clipped to shift start" do
    dtr = make_dtr(date: "2026-05-05", clock_in: "07:00", clock_out: "17:00")
    result = TimeSlicerService.new(dtr).run

    # Should not earn extra pay for the hour before shift starts
    assert_equal 480, result[:total_work_minutes]
  end

  test "returns empty summary when no shift is configured" do
    @employee.update_columns(shift_start: nil, shift_end: nil)
    dtr = make_dtr(date: "2026-05-05", clock_in: "08:00", clock_out: "17:00")
    result = TimeSlicerService.new(dtr).run

    assert_equal 0, result[:total_work_minutes]
    assert_empty result[:slices]
  end

  test "holiday slices are tagged with holiday flag" do
    Holiday.create!(name: "Test Holiday", date: Date.parse("2026-05-05"), holiday_type: "regular")
    dtr = make_dtr(date: "2026-05-05", clock_in: "08:00", clock_out: "17:00")
    result = TimeSlicerService.new(dtr).run

    assert result[:slices].any? { |s| s[:holiday] }, "expected holiday-tagged slices"
  end
end
