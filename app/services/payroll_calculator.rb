# app/services/payroll_calculator.rb
class PayrollCalculator
  def self.calculate_all(employee, reference_date, apply_sss: false, apply_ph: false, apply_pi: false)
    # Current Gross is for display (we can still calculate this from minutes for the UI)
    current_gross = calculate_period_gross_from_minutes(employee, reference_date)
    
    # Contractual Base (Daily Rate * 26)
    projected_monthly = (employee.basic_rate || 0) * 26

    # SSS Logic: Look for the actual Payroll record from last month
    sss_ee = 0.0
    if apply_sss
      # Search for a payroll record in the previous month
      last_month_date = reference_date.last_month
      actual_last_month_pay = lookup_past_payroll_gross(employee, last_month_date)
      
      # If found, use actual. If not (new hire/no history), use Projected Monthly fallback.
      sss_base = actual_last_month_pay > 0 ? actual_last_month_pay : projected_monthly
      sss_ee = calculate_sss_contribution(sss_base)
    end
    
    ph_ee = apply_ph ? calculate_philhealth_contribution(projected_monthly) : 0
    pi_ee = apply_pi ? calculate_pagibig_contribution(projected_monthly) : 0

    {
      current_gross: current_gross.round(2),
      sss_ee: sss_ee.round(2),
      philhealth_ee: ph_ee.round(2),
      pagibig_ee: pi_ee.round(2),
      total_deductions: (sss_ee + ph_ee + pi_ee).round(2)
    }
  end

  private

  # NEW: Looks at the Payroll table for historical data
  def self.lookup_past_payroll_gross(employee, date)
    past_payroll = employee.payrolls
                           .where(start_date: date.beginning_of_month..date.end_of_month)
                           .first # You can add .where(status: 'finalized') if you have a status column
    
    past_payroll ? past_payroll.gross_pay.to_f : 0.0
  end

  # Keep this to show the "Gross Pay" on the current January draft
  def self.calculate_period_gross_from_minutes(employee, date)
    total_minutes = employee.daily_time_records
                            .where(date: date.beginning_of_month..date.end_of_month)
                            .joins(:time_slices)
                            .sum("time_slices.minutes").to_f

    hourly_rate = (employee.basic_rate.to_f / 8.0)
    (total_minutes / 60.0) * hourly_rate
  end

  # (Keep your existing calculate_sss_contribution, ph, and pi methods below...)
  def self.calculate_sss_contribution(salary)
    bracket = GovDeductionBracket.sss.where("range_min <= ? AND range_max >= ?", salary, salary).first
    bracket ? bracket.amount.to_f : 0.0
  end

  def self.calculate_philhealth_contribution(salary)
    bracket = GovDeductionBracket.philhealth.where("range_min <= ? AND range_max >= ?", salary, salary).first
    return (salary * 0.025).round(2) if bracket.nil? || bracket.amount.to_f == 0.0
    bracket.amount.to_f
  end

  def self.calculate_pagibig_contribution(salary)
    bracket = GovDeductionBracket.pagibig.where("range_min <= ? AND range_max >= ?", salary, salary).first
    return 200.0 if bracket.nil?
    # amount: 0 signals percentage-based: 1% for salaries <= 1,500
    bracket.amount.to_f == 0.0 ? (salary * 0.01).round(2) : bracket.amount.to_f
  end
end