class Employee < ApplicationRecord
  has_many :daily_time_records, dependent: :destroy

  DAYS_OF_WEEK = Date::DAYNAMES.freeze
  WORKDAY_DEFAULT = DAYS_OF_WEEK[1..5] # Mon–Fri

  validates :name, presence: true
  validates :person_id, presence: true, uniqueness: true
  validates :work_days, presence: true
  validate  :work_days_are_valid

  before_validation :normalize_work_days
  before_validation :set_rest_days

  # ========================
  # Work/Rest Days Formatting
  # ========================
  def formatted_work_days(short: false)
    return work_days.join(", ") unless short
    work_days.map { |d| d.first(3) }.join(", ")
  end

  def formatted_rest_days(short: false)
    return rest_days.join(", ") unless short
    rest_days.map { |d| d.first(3) }.join(", ")
  end

  # ========================
  # Shift Time Helpers
  # ========================
  # Ensures shift_start is always a Time object
  def shift_start_time
    return nil unless shift_start
    shift_start.is_a?(Time) ? shift_start : Time.parse(shift_start.to_s)
  rescue ArgumentError
    nil
  end

  # Ensures shift_end is always a Time object
  def shift_end_time
    return nil unless shift_end
    shift_end.is_a?(Time) ? shift_end : Time.parse(shift_end.to_s)
  rescue ArgumentError
    nil
  end

  private

  # Normalize work_days array
  def normalize_work_days
    self.work_days = Array(work_days)
                       .map(&:to_s)
                       .map(&:strip)
                       .uniq
  end

  # Set rest_days based on work_days
  def set_rest_days
    self.rest_days = DAYS_OF_WEEK - work_days if work_days.present?
  end

  # Validate work_days contain valid day names
  def work_days_are_valid
    invalid_days = work_days - DAYS_OF_WEEK
    errors.add(:work_days, "contains invalid days: #{invalid_days.join(', ')}") if invalid_days.any?
  end
end
