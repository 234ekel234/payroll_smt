# app/models/pay_multiplier.rb
class PayMultiplier < ApplicationRecord
  HOLIDAY_TYPES = %w[none special regular]

  validates :code, :name, presence: true
  validates :holiday_type, inclusion: { in: HOLIDAY_TYPES }
  validates :base_multiplier, numericality: { greater_than_or_equal_to: 0 }

  scope :match, ->(holiday_type:, rest_day:, overtime:) {
    where(
      holiday_type: holiday_type,
      rest_day: rest_day,
      overtime: overtime
    ).first
  }
end
