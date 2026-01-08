class CreatePayrolls < ActiveRecord::Migration[8.1]
  def change
    create_table :payrolls do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :daily_rate
      t.integer :days_worked
      t.decimal :allowance
      t.decimal :basic_pay
      t.decimal :overtime_pay
      t.decimal :rest_day_pay
      t.decimal :holiday_pay
      t.decimal :night_diff_pay
      t.decimal :gross_pay
      t.decimal :total_deductions
      t.decimal :net_pay
      t.datetime :processed_at
      t.string :status

      t.timestamps
    end
  end
end
