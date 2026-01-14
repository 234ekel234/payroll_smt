class PayrollDeduction < ApplicationRecord
  belongs_to :payroll
  # This is the "source" Rails is looking for
  belongs_to :deduction, optional: true 
end