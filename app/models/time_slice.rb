class TimeSlice < ApplicationRecord
  belongs_to :daily_time_record

  # Attributes: start_time, end_time, minutes, pay, night_diff, holiday, rest_day, multiplier_name
  validates :start_time, :end_time, presence: true
  validates :minutes, numericality: { greater_than_or_equal_to: 0 }
  validates :pay, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  def multiplier
    (multiplier_percent.to_f / 100.0)
  end
  def hours
    (minutes.to_f / 60.0).round(2)
  end
end
