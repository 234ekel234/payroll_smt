class CreateShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :shifts do |t|
      t.string :name
      t.time :shift_start
      t.time :shift_end
      t.time :break_start
      t.time :break_end

      t.timestamps
    end
  end
end
