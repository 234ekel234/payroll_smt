class CreatePayMultipliers < ActiveRecord::Migration[8.1]
  def change
    create_table :pay_multipliers do |t|
      t.string :code
      t.string :name
      t.string :holiday_type
      t.boolean :rest_day
      t.boolean :overtime
      t.decimal :base_multiplier

      t.timestamps
    end
  end
end
