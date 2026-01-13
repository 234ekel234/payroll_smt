class CreateTimeSlices < ActiveRecord::Migration[8.1]
  def change
    create_table :time_slices do |t|
      t.references :daily_time_record, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :minutes
      t.decimal :pay, precision: 12, scale: 2
      t.boolean :night_diff
      t.boolean :holiday
      t.boolean :rest_day
      t.string :multiplier_name

      t.timestamps
    end
  end
end
