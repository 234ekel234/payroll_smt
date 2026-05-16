require "test_helper"

class EmployeeTest < ActiveSupport::TestCase
  def setup
    @employee = employees(:one)
  end

  test "valid employee passes validation" do
    assert @employee.valid?
  end

  test "requires name" do
    @employee.name = nil
    assert_not @employee.valid?
    assert_includes @employee.errors[:name], "can't be blank"
  end

  test "requires person_id" do
    @employee.person_id = nil
    assert_not @employee.valid?
  end

  test "requires unique person_id" do
    duplicate = @employee.dup
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:person_id], "has already been taken"
  end

  test "requires basic_rate greater than zero" do
    @employee.basic_rate = 0
    assert_not @employee.valid?

    @employee.basic_rate = -100
    assert_not @employee.valid?

    @employee.basic_rate = 650
    assert @employee.valid?
  end

  test "rejects invalid work days" do
    @employee.work_days = ["Monday", "Funday"]
    assert_not @employee.valid?
    assert_match(/invalid days/, @employee.errors[:work_days].first)
  end

  test "set_rest_days derives rest_days from work_days" do
    @employee.work_days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    @employee.valid?
    assert_includes @employee.rest_days, "Saturday"
    assert_includes @employee.rest_days, "Sunday"
  end

  test "shift template takes priority over individual columns" do
    shift = Shift.create!(name: "Morning", shift_start: "06:00:00", shift_end: "15:00:00",
                          break_start: "11:00:00", break_end: "12:00:00")
    @employee.shift = shift
    assert_equal shift.shift_start, @employee.effective_shift_start
    assert_equal shift.shift_end, @employee.effective_shift_end
  end

  test "falls back to own columns when no shift template" do
    @employee.shift = nil
    assert_equal @employee.read_attribute(:shift_start), @employee.effective_shift_start
  end
end
