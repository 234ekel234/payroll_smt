class Payroll < ApplicationRecord
  belongs_to :employee
  has_many :payroll_deductions, dependent: :destroy
  has_many :deductions, through: :payroll_deductions
  
  has_many :daily_time_records, ->(payroll) { 
    where(date: payroll.start_date..payroll.end_date) 
  }, through: :employee

  accepts_nested_attributes_for :payroll_deductions, allow_destroy: true, reject_if: :all_blank

  # --- PUBLIC HELPERS ---

  def total_statutory
    sss_amount.to_f + phic_amount.to_f + hdmf_amount.to_f
  end

  # Safety Helpers for Excel and Calculations
  def sss_loan; self[:sss_loan].to_f; end
  def hdmf_loan; self[:hdmf_loan].to_f; end
  def cash_advance; self[:cash_advance].to_f; end
  def rice_deduction; self[:rice_deduction].to_f; end
  def materials_deduction; self[:materials_deduction].to_f; end
  def groceries_deduction; self[:groceries_deduction].to_f; end
  def late_ut_amount; self[:late_ut_amount].to_f; end

  # --- CORE LOGIC ---

  def apply_all_deductions(standard_ids: [], sss: false, ph: false, pi: false)
    transaction do
      # 1. Clear existing snapshots to ensure a fresh calculation (Prevents doubling on re-run)
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
    # A. Sum of Fixed Columns
    fixed_deductions = total_statutory + sss_loan + hdmf_loan + cash_advance + 
                       rice_deduction + materials_deduction + groceries_deduction + 
                       late_ut_amount

    # B. Sum of Line Items (CRITICAL: Exclude "Statutory" notes to prevent double-counting)
    # This only sums manual/standard deductions that aren't already in the fixed columns.
    line_item_total = payroll_deductions.reload.where.not(note: "Statutory").sum(:amount)
    
    total = (fixed_deductions + line_item_total).round(2)
    
    update_columns(
      total_deductions: total,
      net_pay: [(gross_pay.to_f - total), 0].max.round(2)
    )
  end

  private

  def apply_standard_deductions(selected_ids)
    ids = Array(selected_ids).reject(&:blank?)
    return if ids.empty?

    Deduction.where(id: ids).each do |d|
      self.payroll_deductions.create!(
        deduction: d,
        amount: d.amount.to_f,
        note: "Standard Deduction"
      )
    end
  end

  def apply_statutory_deductions(sss, ph, pi)
    results = PayrollCalculator.calculate_all(
      self.employee,
      self.start_date,
      apply_sss: sss,
      apply_ph:  ph,
      apply_pi:  pi
    )

    # Save to fixed columns
    updates = {
      sss_amount: sss ? results[:sss_ee] : 0,
      phic_amount: ph ? results[:philhealth_ee] : 0,
      hdmf_amount: pi ? results[:pagibig_ee] : 0
    }

    # Create line items for audit trail (labeled "Statutory" so they are excluded from the sum)
    if sss && (m = Deduction.find_by("name ILIKE ?", "%SSS%"))
      self.payroll_deductions.create!(deduction: m, amount: results[:sss_ee], note: "Statutory")
    end

    if ph && (m = Deduction.find_by("name ILIKE ?", "%PHIC%"))
      self.payroll_deductions.create!(deduction: m, amount: results[:philhealth_ee], note: "Statutory")
    end

    if pi && (m = Deduction.find_by("name ILIKE ?", "%HDMF%"))
      self.payroll_deductions.create!(deduction: m, amount: results[:pagibig_ee], note: "Statutory")
    end

    update_columns(updates)
  end
end