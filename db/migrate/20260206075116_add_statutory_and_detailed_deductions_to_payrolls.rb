class AddStatutoryAndDetailedDeductionsToPayrolls < ActiveRecord::Migration[8.1]
  def change
    add_column :payrolls, :sss_amount, :decimal
    add_column :payrolls, :phic_amount, :decimal
    add_column :payrolls, :hdmf_amount, :decimal
    add_column :payrolls, :sss_loan, :decimal
    add_column :payrolls, :hdmf_loan, :decimal
    add_column :payrolls, :cash_advance, :decimal
    add_column :payrolls, :rice_deduction, :decimal
    add_column :payrolls, :materials_deduction, :decimal
    add_column :payrolls, :groceries_deduction, :decimal
    add_column :payrolls, :late_ut_amount, :decimal
  end
end
