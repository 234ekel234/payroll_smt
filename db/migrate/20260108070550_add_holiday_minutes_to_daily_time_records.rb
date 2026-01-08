class AddHolidayMinutesToDailyTimeRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :daily_time_records, :holiday_minutes, :integer
  end
end
