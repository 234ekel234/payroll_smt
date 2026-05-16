class AddAbsentHolidayPayToPayrolls < ActiveRecord::Migration[8.1]
  def change
    add_column :payrolls, :absent_holiday_pay, :decimal, precision: 10, scale: 2, default: 0
  end
end
