class Employee < ApplicationRecord
  # == Associations ==
  has_many :daily_time_records, dependent: :destroy

  # == Constants ==
  DAYS_OF_WEEK = Date::DAYNAMES.freeze

  # == Validations ==
  validates :name, presence: true
  validates :person_id, presence: true, uniqueness: true

  validates :basic_rate,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :allowance_per_day,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :work_days,
            presence: true

  validate :work_days_are_valid

  # == Callbacks ==
  before_validation :normalize_work_days
  before_validation :set_rest_days

  # == Instance Methods ==
  def formatted_work_days
    work_days.join(", ")
  end

  def formatted_rest_days
    rest_days.join(", ")
  end

  private

  # Ensure work_days is clean and consistent
  def normalize_work_days
    self.work_days ||= []
    self.work_days = work_days.reject(&:blank?).uniq
  end

  # Derive rest days from work days
  def set_rest_days
    self.rest_days = DAYS_OF_WEEK - work_days
  end

  # Custom validation
  def work_days_are_valid
    invalid_days = work_days - DAYS_OF_WEEK
    if invalid_days.any?
      errors.add(:work_days, "contains invalid days: #{invalid_days.join(', ')}")
    end
  end
end
