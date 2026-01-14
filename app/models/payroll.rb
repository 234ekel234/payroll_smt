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
    # Ensure selected_master_ids is an array of IDs, filtering out blanks
    selected_ids = Array(selected_master_ids).reject(&:blank?)

    transaction do
      # 1. Clear existing MASTER deductions (keep manual ones)
      self.payroll_deductions.where.not(deduction_id: nil).destroy_all

      # 2. Add Master Deductions (SSS, PhilHealth, etc.)
      if selected_ids.any?
        Deduction.where(id: selected_ids).each do |d|
          # We pass gross_pay to the deduction model to handle percentage math
          amt = d.calculate_for(self.gross_pay.to_f)
          
          self.payroll_deductions.create!(
            deduction: d, 
            amount: amt, 
            note: d.name
          )
        end
      end

      # 3. Final Tally
      # Use reload to ensure we are summing the newly created records + manual ones
      total = self.payroll_deductions.reload.sum(:amount)
      
      self.update_columns(
        total_deductions: total,
        net_pay: (self.gross_pay.to_f) - total
      )
    end
  end
end