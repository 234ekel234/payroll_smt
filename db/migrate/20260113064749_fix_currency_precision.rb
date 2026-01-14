class FixCurrencyPrecision < ActiveRecord::Migration[8.1]
  def change
    # Update Payroll totals
    change_column :payrolls, :gross_pay, :decimal, precision: 12, scale: 2
    change_column :payrolls, :net_pay, :decimal, precision: 12, scale: 2
    change_column :payrolls, :total_deductions, :decimal, precision: 12, scale: 2
    
    # Update Master Deductions
    change_column :deductions, :amount, :decimal, precision: 12, scale: 2
    
    # Update Junction Table
    change_column :payroll_deductions, :amount, :decimal, precision: 12, scale: 2
  end
end
