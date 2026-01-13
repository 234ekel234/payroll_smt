class AddFlagsToTimeSlices < ActiveRecord::Migration[8.1]
  def change
    change_table :time_slices do |t|
      # Flag for slices that count as overtime
      t.boolean :overtime, default: false, null: false

      # Minutes for late/early leave slices
      t.integer :late, default: 0, null: false
      t.integer :early_leave, default: 0, null: false

      # Store the total multiplier applied (base_multiplier + night_diff %)
      t.decimal :multiplier_percent, precision: 5, scale: 2
    end
  end
end
