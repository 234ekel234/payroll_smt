class PayrollGenerator
  def initialize(start_date:, end_date:, employees:, deduction_ids: [])
    @start_date    = start_date
    @end_date      = end_date
    @employees     = Array(employees)
    @deduction_ids = deduction_ids
  end

  def generate!
    Payroll.transaction do
      @employees.each do |employee|
        # 1. Clear existing 'draft' records for this period
        Payroll.where(
          employee: employee, 
          start_date: @start_date, 
          end_date: @end_date, 
          status: 'draft'
        ).destroy_all
        
        process_employee(employee)
      end
    end
  end

  private

  def process_employee(employee)
    hourly_rate = employee.basic_rate.to_f / 8.0
    
    # 1. Gather Attendance Records
    period_dtrs = employee.daily_time_records.where(date: @start_date..@end_date)
    dtr_ids     = period_dtrs.pluck(:id)
    days_present = dtr_ids.count
    
    # Calculate total allowance based on presence
    total_allowance = (employee.allowance_per_day.to_f * days_present)

    # 2. Fetch Slices
    slices = TimeSlice.where(daily_time_record_id: dtr_ids)

    totals = {
      basic_pay: 0.0,
      overtime_pay: 0.0,
      holiday_pay: 0.0,
      rest_day_pay: 0.0,
      night_diff_pay: 0.0
    }

    slices.each do |slice|
      duration_mins = slice.minutes.to_f
      next if duration_mins <= 0

      # Multiplier logic
      m_percent = slice.multiplier_percent.to_f > 0 ? slice.multiplier_percent.to_f : 100.0
      multiplier = m_percent / 100.0
      
      # Base calculation for the segment
      slice_money = (duration_mins / 60.0) * hourly_rate * multiplier
      
      # --- THE PRIORITY FILTER (Mutually Exclusive) ---
      is_holiday = slice.holiday == true || slice.multiplier_code&.start_with?("RH", "SNWH")
      is_rest    = slice.rest_day == true || slice.multiplier_code&.include?("RD")

      if is_holiday
        totals[:holiday_pay] += slice_money
      elsif is_rest
        totals[:rest_day_pay] += slice_money
      elsif slice.overtime == true
        totals[:overtime_pay] += slice_money
      else
        totals[:basic_pay] += slice_money
      end

      # --- ADDITIVE PREMIUM (Option A) ---
      if slice.night_diff == true
        totals[:night_diff_pay] += (duration_mins / 60.0) * hourly_rate * 0.10
      end
    end

    # 3. Summation
    total_earnings = totals[:basic_pay] + totals[:overtime_pay] + 
                     totals[:holiday_pay] + totals[:rest_day_pay] + 
                     totals[:night_diff_pay]
    
    gross_pay = total_earnings + total_allowance

    # 4. Persistence (Removed late_deduction attribute)
    payroll = Payroll.create!(
      employee: employee,
      start_date: @start_date,
      end_date: @end_date,
      daily_rate: employee.basic_rate,
      days_worked: days_present,
      basic_pay: totals[:basic_pay],
      allowance: total_allowance,
      overtime_pay: totals[:overtime_pay],
      holiday_pay: totals[:holiday_pay],
      rest_day_pay: totals[:rest_day_pay],
      night_diff_pay: totals[:night_diff_pay],
      gross_pay: gross_pay.round(2),
      net_pay: gross_pay.round(2),
      status: "draft",
      processed_at: Time.current
    )

    # 5. Apply selected deductions (SSS, PhilHealth, etc.)
    payroll.apply_deductions(@deduction_ids) if @deduction_ids.present?
    
    payroll
  end
end