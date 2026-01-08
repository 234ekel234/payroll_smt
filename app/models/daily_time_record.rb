# app/models/daily_time_record.rb
class DailyTimeRecord < ApplicationRecord
  belongs_to :employee

  # ========================
  # Validations
  # ========================
  validates :date, presence: true
  validate  :no_time_overlap

  # ========================
  # Callbacks
  # ========================
  before_validation :adjust_night_shift
  before_save       :compute_attendance_minutes_and_abnormal

  # ========================
  # Public Methods
  # ========================

  # Total work minutes within shift, minus break
  def total_work_minutes
    return 0 unless valid_times? && employee&.shift_start_time && employee&.shift_end_time

    shift_start = shift_start_for_date.to_time
    shift_end   = shift_end_for_date.to_time

    # Clip clock_in/out to shift boundaries
    effective_start = [clock_in, shift_start].max
    effective_end   = [normalized_clock_out, shift_end].min
    return 0 unless effective_end > effective_start

    ((effective_end - effective_start).to_f / 60).to_i - total_break_minutes
  end

  # Total break minutes from employee
  def total_break_minutes
    return 0 unless employee&.break_start.is_a?(Time) && employee&.break_end.is_a?(Time)

    break_start_dt = DateTime.new(date.year, date.month, date.day,
                                  employee.break_start.hour,
                                  employee.break_start.min,
                                  employee.break_start.sec)
    break_end_dt   = DateTime.new(date.year, date.month, date.day,
                                  employee.break_end.hour,
                                  employee.break_end.min,
                                  employee.break_end.sec)
    ((break_end_dt - break_start_dt).to_f / 60).to_i
  end

  # ========================
  # Attendance Calculations
  # Stored in DB
  # ========================
  def compute_attendance_minutes_and_abnormal
    self.late_minutes        = calculate_late_minutes
    self.early_leave_minutes = calculate_early_leave_minutes
    self.overtime_minutes    = calculate_overtime_minutes
    self.night_diff_minutes  = calculate_night_diff_minutes
    self.holiday_minutes     = calculate_holiday_minutes
    flag_abnormal_situations
  end

  # ========================
  # Minute Calculations
  # ========================

  def calculate_late_minutes
    return 0 unless valid_times? && employee&.shift_start_time
    shift_start = shift_start_for_date.to_time
    grace_end   = shift_start + 5.minutes
    return 0 if clock_in <= grace_end
    ((clock_in - shift_start).to_f / 60).to_i
  end

  def calculate_early_leave_minutes
    return 0 unless valid_times? && employee&.shift_end_time
    co = normalized_clock_out
    return 0 unless co.is_a?(Time)
    shift_end = shift_end_for_date.to_time
    diff = ((shift_end - co).to_f / 60)
    diff.positive? ? diff.to_i : 0
  end

  def calculate_overtime_minutes
    return 0 unless valid_times? && employee&.shift_end_time
    shift_end = shift_end_for_date.to_time
    grace_end = shift_end + 30.minutes
    return 0 if normalized_clock_out <= grace_end
    ((normalized_clock_out - shift_end).to_f / 60).to_i
  end

  def calculate_night_diff_minutes
    return 0 unless valid_times?
    night_start = clock_in.change(hour: 22, min: 0)
    night_end   = (clock_in + 1.day).change(hour: 6, min: 0)
    overlap_start = [clock_in, night_start].max
    overlap_end   = [normalized_clock_out, night_end].min
    return 0 unless overlap_end > overlap_start
    ((overlap_end - overlap_start).to_f / 60).to_i
  end

  # Holiday minutes: compute only minutes worked on holidays
  def calculate_holiday_minutes
    return 0 unless valid_times? && employee

    # Find holidays that apply to this employee and date
    holidays = Holiday.where(date: date)
    return 0 if holidays.empty?

    total_minutes = 0

    holidays.each do |h|
      # Whole day holiday
      holiday_start = date.beginning_of_day
      holiday_end   = date.end_of_day

      overlap_start = [clock_in, holiday_start].max
      overlap_end   = [normalized_clock_out, holiday_end].min
      next unless overlap_end > overlap_start

      total_minutes += ((overlap_end - overlap_start).to_f / 60).to_i
    end

    total_minutes
  end





  # ========================
  # Abnormal Situations
  # ========================
  def flag_abnormal_situations
    issues = []

    issues << "Absent during shift" if total_work_minutes == 0 && valid_times? && (clock_in > shift_end_for_date || normalized_clock_out < shift_start_for_date)
    issues << "Late" if late_minutes.to_i > 0
    issues << "Early leave" if early_leave_minutes.to_i > 0
    issues << "Overtime" if overtime_minutes.to_i > 0
    issues << "Night shift only" if total_work_minutes == 0 && night_diff_minutes.to_i > 0
    issues << "Holiday Work" if holiday_minutes.to_i > 0

    self.abnormal_situation = issues.any? ? issues.join(", ") : nil
  end

  # ========================
  # Private Helpers
  # ========================
  private

  def valid_times?
    clock_in.is_a?(Time) && clock_out.is_a?(Time)
  end

  def adjust_night_shift
    return unless valid_times?
    self.clock_out += 1.day if clock_out <= clock_in
  end

  def normalized_clock_out
    return nil unless valid_times?
    clock_out <= clock_in ? clock_out + 1.day : clock_out
  end

  def shift_start_for_date
    return nil unless employee&.shift_start_time
    DateTime.new(clock_in.year, clock_in.month, clock_in.day,
                 employee.shift_start_time.hour,
                 employee.shift_start_time.min,
                 employee.shift_start_time.sec)
  end

  def shift_end_for_date
    return nil unless employee&.shift_end_time
    dt = DateTime.new(clock_in.year, clock_in.month, clock_in.day,
                      employee.shift_end_time.hour,
                      employee.shift_end_time.min,
                      employee.shift_end_time.sec)
    dt += 1.day if dt <= shift_start_for_date
    dt
  end

  def no_time_overlap
    return unless valid_times? && employee
    overlapping = employee.daily_time_records
                      .where(date: date)
                      .where.not(id: id)
                      .where("clock_in < ? AND clock_out > ?", normalized_clock_out, clock_in)
    errors.add(:base, "Time record overlaps with existing record for this employee") if overlapping.exists?
  end
end
