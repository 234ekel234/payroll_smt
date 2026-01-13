class DropMultipliersTable < ActiveRecord::Migration[8.1]
  def up
    drop_table :multipliers, if_exists: true
  end

  def down
    # Optional: recreate table in case you need to rollback
    create_table :multipliers do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :holiday, default: false
      t.boolean :night_diff, default: false
      t.boolean :not_worked, default: false
      t.boolean :overtime, default: false
      t.decimal :percentage, precision: 5, scale: 2, default: "0.0"
      t.boolean :regular_holiday, default: false
      t.boolean :rest_day, default: false
      t.boolean :special_holiday, default: false
      t.timestamps
    end
  end
end
