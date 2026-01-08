class AddLateAndEarlyLeaveToDailyTimeRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :daily_time_records, :late_minutes, :integer
    add_column :daily_time_records, :early_leave_minutes, :integer
  end
end
