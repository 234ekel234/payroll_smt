class CreateDailyTimeRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_time_records do |t|
      t.references :employee, null: false, foreign_key: true
      t.date :date
      t.datetime :clock_in
      t.datetime :clock_out
      t.integer :night_diff_minutes
      t.integer :overtime_minutes
      t.string :abnormal_situation

      t.timestamps
    end
  end
end
