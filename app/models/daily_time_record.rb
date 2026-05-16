class DailyTimeRecord < ApplicationRecord
  belongs_to :employee
  has_many :time_slices, dependent: :destroy

  # 1. Fix the date if it's an overnight shift
  before_validation :fix_overnight_clock_out, if: -> { clock_in && clock_out && (clock_in_changed? || clock_out_changed?) }

  # 2. Calculate the segments and totals
  before_save :process_attendance_logic, if: -> { clock_in_changed? || clock_out_changed? || date_changed? }

  def total_work_minutes
    time_slices.map(&:minutes).sum
  end

  private

  def fix_overnight_clock_out
    if clock_out <= clock_in
      self.clock_out += 1.day
    end
  end

  def process_attendance_logic
    return unless clock_in && clock_out
    
    # Run the Service
    summary = TimeSlicerService.new(self).run

    # Assign Totals
    self.late_minutes        = summary[:late_minutes]
    self.overtime_minutes    = summary[:overtime_minutes]
    self.night_diff_minutes  = summary[:night_diff_minutes]
    self.holiday_minutes     = summary[:holiday_minutes]
    
    # REFRESH SLICES:
    # .clear removes the old slices from the association in memory.
    # Because 'dependent: :destroy' is set on the has_many, Rails will 
    # delete the old records from the DB when this DTR saves.
    time_slices.clear 
    
    summary[:slices].each do |s_data|
      time_slices.build(s_data)
    end

    self.abnormal_situation = build_abnormal_string(summary)
  end

  def build_abnormal_string(summary)
    issues = []
    issues << "Late"    if (late_minutes || 0) > 0
    issues << "OT"      if (overtime_minutes || 0) > 0
    issues << "Holiday" if (holiday_minutes || 0) > 0
    issues << "Absent"  if summary[:total_work_minutes] == 0
    
    issues.any? ? issues.join(", ") : nil
  end
end