# app/models/daily_time_record.rb
class DailyTimeRecord < ApplicationRecord
  belongs_to :employee

  # Validations
  validates :date, :clock_in, :clock_out, presence: true

  # ========================
  # Derived Calculations
  # ========================

  # Total work minutes, handles overnight shifts
  def total_work_minutes
    return 0 unless clock_in && clock_out

    if clock_out < clock_in
      ((clock_out + 1.day - clock_in) / 60).to_i
    else
      ((clock_out - clock_in) / 60).to_i
    end
  end

  # Night differential: minutes between 10 PM and 6 AM
  def night_diff_minutes
    return 0 unless clock_in && clock_out

    night_start = clock_in.change(hour: 22, min: 0) # 10 PM
    night_end = clock_in + 1.day
    night_end = night_end.change(hour: 6, min: 0)   # 6 AM next day

    # Adjust for overnight shifts
    work_start = clock_in
    work_end = clock_out < clock_in ? clock_out + 1.day : clock_out

    overlap_start = [work_start, night_start].max
    overlap_end   = [work_end, night_end].min

    diff = ((overlap_end - overlap_start) / 60).to_i
    diff.positive? ? diff : 0
  end

  # Overtime minutes: starts 30 mins after shift end
  def overtime_minutes
    return 0 unless clock_out && employee.shift_end

    shift_end = employee.shift_end
    shift_end += 1.day if employee.shift_start > employee.shift_end # overnight shift

    ot_start = shift_end + 30.minutes
    work_end = clock_out < clock_in ? clock_out + 1.day : clock_out

    diff = ((work_end - ot_start) / 60).to_i
    diff.positive? ? diff : 0
  end

  # Early leave minutes: clocking out before shift end
  def early_leave_minutes
    return 0 unless clock_out && employee.shift_end

    shift_end = employee.shift_end
    shift_end += 1.day if employee.shift_start > employee.shift_end # overnight shift

    diff = ((shift_end - clock_out) / 60).to_i
    diff.positive? ? diff : 0
  end

  # Late minutes: clocking in 5+ mins after shift start
  def late_minutes
    return 0 unless clock_in && employee.shift_start

    shift_start = employee.shift_start
    shift_start += 1.day if employee.shift_end < employee.shift_start # overnight shift

    diff = ((clock_in - shift_start) / 60).to_i - 5 # 5-minute grace period
    diff.positive? ? diff : 0
  end

  # Total break minutes, can be added if you track break_start/break_end
  def total_break_minutes
    return 0 unless break_start && break_end
    ((break_end - break_start) / 60).to_i
  end
end
