class PayrollCalculator
  # Main entry point for the "Semi-Auto Toggle" logic
  def self.calculate_all(employee, reference_date, apply_sss: false, apply_ph: false, apply_pi: false)
    # 1. Calculate Current Gross based on DTR/TimeSlices
    current_gross = calculate_period_gross(employee, reference_date)
    
    # 2. SSS: Uses previous month's actual gross for bracket lookup
    sss_ee = apply_sss ? calculate_sss_contribution(employee, reference_date.last_month) : 0
    
    # 3. PhilHealth & Pag-IBIG: Uses projected monthly (Basic Rate * 26)
    projected_monthly = employee.basic_rate * 26
    ph_ee = apply_ph ? calculate_philhealth_contribution(projected_monthly) : 0
    pi_ee = apply_pi ? calculate_pagibig_contribution(projected_monthly) : 0

    total_ee_deductions = sss_ee + ph_ee + pi_ee

    {
      current_gross: current_gross,
      projected_monthly: projected_monthly,
      sss_ee: sss_ee,
      philhealth_ee: ph_ee,
      pagibig_ee: pi_ee,
      total_deductions: total_ee_deductions,
      net_pay: current_gross - total_ee_deductions
    }
  end

  private

  # Calculate Gross from TimeSlices (Most accurate for your schema)
  def self.calculate_period_gross(employee, date)
    start_d = date.beginning_of_month
    end_d = date.end_of_month

    # Summing the 'pay' column from your time_slices through daily_time_records
    employee.daily_time_records
            .where(date: start_d..end_d)
            .joins(:time_slices)
            .sum("time_slices.pay")
  end

  # SSS LOOKUP (Matches your 500-step seeds)
  def self.calculate_sss_contribution(employee, date)
    # SSS uses the "Actual" gross from the previous month
    salary = calculate_period_gross(employee, date)
    
    bracket = GovDeductionBracket.sss
                                 .where("range_min <= ? AND range_max >= ?", salary, salary)
                                 .first
    # Fallback to max bracket if salary exceeds max seed
    bracket ||= GovDeductionBracket.sss.order(range_max: :desc).first
    bracket&.amount || 0
  end

  # PHILHEALTH FORMULA (Handles your '0' amount seed for the middle bracket)
  def self.calculate_philhealth_contribution(salary)
    bracket = GovDeductionBracket.philhealth
                                 .where("range_min <= ? AND range_max >= ?", salary, salary)
                                 .first
    return 0 unless bracket

    # If the seed amount is 0, it's the 2.5% formula bracket
    if bracket.amount == 0
      (salary * 0.025).round(2)
    else
      bracket.amount
    end
  end

  # PAG-IBIG LOOKUP
  def self.calculate_pagibig_contribution(salary)
    bracket = GovDeductionBracket.pagibig
                                 .where("range_min <= ? AND range_max >= ?", salary, salary)
                                 .first
    bracket&.amount || 0
  end
end