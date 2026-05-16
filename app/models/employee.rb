class Employee < ApplicationRecord
  # --- Associations ---
  belongs_to :shift, optional: true # The new template association
  
  has_many :daily_time_records, dependent: :destroy
  has_many :payrolls, dependent: :destroy
  
  # This join table stores the default/permanent deductions for this employee
  has_many :employee_deductions, dependent: :destroy
  has_many :deductions, through: :employee_deductions

  # --- Constants ---
  DAYS_OF_WEEK = Date::DAYNAMES.freeze
  WORKDAY_DEFAULT = DAYS_OF_WEEK[1..5] # Mon–Fri

  # --- Validations ---
  validates :name, presence: true
  validates :person_id, presence: true, uniqueness: true
  validates :basic_rate, presence: true, numericality: { greater_than: 0 }
  validates :work_days, presence: true
  validate  :work_days_are_valid

  # --- Callbacks ---
  before_validation :normalize_work_days
  before_validation :set_rest_days

  # --- Custom Methods ---
  
  # Returns the group shift time if assigned, otherwise falls back to local column
  def effective_shift_start
    shift&.shift_start || read_attribute(:shift_start)
  end

  def effective_shift_end
    shift&.shift_end || read_attribute(:shift_end)
  end
  def break_start_time
    shift&.break_start || break_start
  end

  def break_end_time
    shift&.break_end || break_end
  end

  # The "Safe Calculation" Helper: 
  # Moves the Year 2000 shift time to the actual date of the DTR.
  def expected_start_on(date)
    base_time = effective_shift_start
    return nil unless base_time
    
    # .change resets the year/month/day but keeps the hours/minutes/seconds
    base_time.change(year: date.year, month: date.month, day: date.day)
  end

  def expected_end_on(date)
    base_time = effective_shift_end
    return nil unless base_time
    base_time.change(year: date.year, month: date.month, day: date.day)
  end

  # Shift Time Helpers for UI Display
  def shift_start_time
    time_val = effective_shift_start
    return nil unless time_val
    time_val.is_a?(Time) ? time_val : Time.parse(time_val.to_s)
  rescue ArgumentError
    nil
  end

  def shift_end_time
    time_val = effective_shift_end
    return nil unless time_val
    time_val.is_a?(Time) ? time_val : Time.parse(time_val.to_s)
  rescue ArgumentError
    nil
  end

  # Used to pre-check checkboxes in forms
  def default_deduction_ids
    deductions.pluck(:id)
  end

  # Work/Rest Days Formatting
  def formatted_work_days(short: false)
    return work_days.join(", ") unless short
    work_days.map { |d| d.first(3) }.join(", ")
  end

  def formatted_rest_days(short: false)
    return rest_days.join(", ") unless short
    rest_days.map { |d| d.first(3) }.join(", ")
  end

  private

  def normalize_work_days
    self.work_days = Array(work_days)
                       .map(&:to_s)
                       .map(&:strip)
                       .uniq
  end

  def set_rest_days
    self.rest_days = DAYS_OF_WEEK - work_days if work_days.present?
  end

  def work_days_are_valid
    invalid_days = work_days - DAYS_OF_WEEK
    errors.add(:work_days, "contains invalid days: #{invalid_days.join(', ')}") if invalid_days.any?
  end
end