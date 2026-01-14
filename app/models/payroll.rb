class Payroll < ApplicationRecord
  belongs_to :employee
  has_many :payroll_deductions, dependent: :destroy
  has_many :deductions, through: :payroll_deductions
  
  # Corrected DTR association
  has_many :daily_time_records, ->(payroll) { 
    where(date: payroll.start_date..payroll.end_date) 
  }, through: :employee

  accepts_nested_attributes_for :payroll_deductions, allow_destroy: true, reject_if: :all_blank

  def apply_deductions(selected_master_ids)
    selected_ids = Array(selected_master_ids).reject(&:blank?)

    transaction do
      # 1. Clear only Master deductions (linked to the Deduction table)
      # This leaves manual notes alone, but we no longer need to "protect" Lateness 
      # because it's not a deduction record anymore.
      self.payroll_deductions.where.not(deduction_id: nil).destroy_all

      # 2. Add Master Deductions
      if selected_ids.any?
        Deduction.where(id: selected_ids).each do |d|
          amt = d.calculate_for(self.gross_pay.to_f)
          self.payroll_deductions.create!(
            deduction: d, 
            amount: amt, 
            note: d.name
          )
        end
      end

      # 3. Final Tally
      total = self.payroll_deductions.reload.sum(:amount)
      
      self.update_columns(
        total_deductions: total,
        net_pay: (self.gross_pay.to_f) - total
      )
    end
  end
end