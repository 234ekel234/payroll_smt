class Payroll < ApplicationRecord
  belongs_to :employee
  has_many :payroll_deductions, dependent: :destroy
  has_many :deductions, through: :payroll_deductions
  
  # DTR association - automatically finds records within the payroll period
  has_many :daily_time_records, ->(payroll) { 
    where(date: payroll.start_date..payroll.end_date) 
  }, through: :employee

  accepts_nested_attributes_for :payroll_deductions, allow_destroy: true, reject_if: :all_blank

  # The Unified Logic for applying both Standard and Statutory Deductions
  def apply_all_deductions(standard_ids: [], sss: false, ph: false, pi: false)
    transaction do
      # 1. Clear existing snapshots to ensure a fresh calculation
      self.payroll_deductions.destroy_all

      # 2. Apply Standard Master Deductions (Loans, Uniforms, etc.)
      apply_standard_deductions(standard_ids)

      # 3. Apply Statutory Deductions (SSS, PhilHealth, Pag-IBIG)
      apply_statutory_deductions(sss, ph, pi)

      # 4. Final Tally & Save
      calculate_final_amounts!
    end
  end

  def calculate_final_amounts!
    total = payroll_deductions.reload.sum(:amount)
    # update_columns avoids infinite loops by skipping callbacks
    update_columns(
      total_deductions: total,
      net_pay: [(gross_pay.to_f - total), 0].max.round(2)
    )
  end

  private

  def apply_standard_deductions(selected_ids)
    ids = Array(selected_ids).reject(&:blank?)
    return if ids.empty?

    # We fetch only the specific IDs checked in the form
    Deduction.where(id: ids).each do |d|
      self.payroll_deductions.create!(
        deduction: d,
        amount: d.calculate_for(self.gross_pay.to_f),
        note: nil # View will default to Master Name
      )
    end
  end

  def apply_statutory_deductions(sss, ph, pi)
    # Use our Service to get the exact 2026 Philippine Law amounts
    results = PayrollCalculator.calculate_all(
      self.employee,
      self.start_date,
      apply_sss: sss,
      apply_ph:  ph,
      apply_pi:  pi
    )

    # SEARCH LOGIC: We use ILIKE (Case-Insensitive) to find the master records
    # This prevents the "missing deductions" error if names are slightly different
    if sss
      m = Deduction.where("name ILIKE ?", "%SSS%").first
      self.payroll_deductions.create!(deduction: m, amount: results[:sss_ee], note: nil) if m
    end

    if ph
      m = Deduction.where("name ILIKE ?", "%PhilHealth%").first
      self.payroll_deductions.create!(deduction: m, amount: results[:philhealth_ee], note: nil) if m
    end

    if pi
      m = Deduction.where("name ILIKE ?", "%Pag-IBIG%").or(Deduction.where("name ILIKE ?", "%HDMF%")).first
      self.payroll_deductions.create!(deduction: m, amount: results[:pagibig_ee], note: nil) if m
    end
  end
end