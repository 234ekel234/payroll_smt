class CreateEmployeeDeductions < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_deductions do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :deduction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
