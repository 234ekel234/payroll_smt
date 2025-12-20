class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :person_id
      t.string :company
      t.string :status_of_employment
      t.string :schedule
      t.decimal :basic_rate
      t.decimal :allowance_per_day
      t.boolean :landbank_atm
      t.time :shift_start
      t.time :shift_end
      t.time :break_start
      t.time :break_end

      t.timestamps
    end
  end
end
