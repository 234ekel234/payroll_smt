class CreateHolidays < ActiveRecord::Migration[8.1]
  def change
    create_table :holidays do |t|
      t.date :date
      t.string :holiday_type
      t.string :name
      t.string :applies_to
      t.text :notes

      t.timestamps
    end
  end
end
