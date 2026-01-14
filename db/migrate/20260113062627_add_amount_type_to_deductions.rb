class AddAmountTypeToDeductions < ActiveRecord::Migration[8.1]
  def change
    add_column :deductions, :amount_type, :integer
  end
end
