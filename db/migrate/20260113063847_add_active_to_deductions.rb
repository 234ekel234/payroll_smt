class AddActiveToDeductions < ActiveRecord::Migration[8.1]
  def change
    add_column :deductions, :active, :boolean
  end
end
