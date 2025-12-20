# app/models/employee.rb
class Employee < ApplicationRecord
  # == Validations ==
  validates :name, presence: true
  validates :person_id, presence: true, uniqueness: true

  validates :basic_rate,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :allowance_per_day,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # No shift-hour validation because of overnight work
  # Work/Rest days stored as text arrays
end
