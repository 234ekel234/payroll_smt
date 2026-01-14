class EmployeeDeduction < ApplicationRecord
  belongs_to :employee
  belongs_to :deduction
end
