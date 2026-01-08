class Payroll < ApplicationRecord
  belongs_to :employee
  # has_many :payroll_deductions, dependent: :destroy
  has_many :daily_time_records, ->(payroll) { where(date: payroll.start_date..payroll.end_date) }, through: :employee
end
