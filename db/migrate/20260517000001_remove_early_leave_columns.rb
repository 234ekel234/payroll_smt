class RemoveEarlyLeaveColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :daily_time_records, :early_leave_minutes, :integer
    remove_column :time_slices, :early_leave, :integer
  end
end
