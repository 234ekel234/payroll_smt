class AddShiftToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_reference :employees, :shift, null: true, foreign_key: true
  end
end
