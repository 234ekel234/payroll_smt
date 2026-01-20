class AddActiveToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :active, :boolean, default: true
  end
end
