# The class name must match the filename (CamelCased)
class AllowManualPayrollDeductions < ActiveRecord::Migration[8.1]
  def change
    add_column :payroll_deductions, :note, :string
    # This allows a record to exist without being linked to the Master Deduction list
    change_column_null :payroll_deductions, :deduction_id, true
  end
end