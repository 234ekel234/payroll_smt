class AddUniqueIndexToEmployeesPersonId < ActiveRecord::Migration[7.1]
  def change
    add_index :employees, :person_id, unique: true
  end
end
