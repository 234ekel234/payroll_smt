class AddWorkDaysAndRestDaysToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :work_days, :text, array: true, default: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
    add_column :employees, :rest_days, :text, array: true, default: ['Sat', 'Sun']
  end
end
