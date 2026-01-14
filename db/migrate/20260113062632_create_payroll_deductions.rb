class CreatePayrollDeductions < ActiveRecord::Migration[8.1]
  def change
    create_table :payroll_deductions do |t|
      t.references :payroll, null: false, foreign_key: true
      t.references :deduction, null: false, foreign_key: true
      t.decimal :amount

      t.timestamps
    end
  end
end
