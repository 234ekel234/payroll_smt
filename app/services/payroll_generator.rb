class PayrollGenerator
  def initialize(start_date:, end_date:, employees:, deduction_ids: [], sss: false, ph: false, pi: false)
    @start_date    = start_date
    @end_date      = end_date
    @employees     = Array(employees)
    @deduction_ids = deduction_ids
    @sss           = sss
    @ph            = ph
    @pi            = pi
  end

  def generate!
    Payroll.transaction do
      @employees.each do |employee|
        # 1. Clear existing 'draft' records for this period
        # This ensures that if you change a Master Deduction name and re-run, 
        # the new names show up on the payslip.
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
    # Assume 8-hour workday for hourly rate calculation
    hourly_rate = employee.basic_rate.to_f / 8.0
    
    # 1. Gather Attendance Records
    period_dtrs = employee.daily_time_records.where(date: @start_date..@end_date)
    dtr_ids     = period_dtrs.pluck(:id)
    days_present = dtr_ids.count
    
    # Calculate total allowance based on days present
    total_allowance = (employee.allowance_per_day.to_f * days_present)

    # 2. Fetch Time Slices (Granular minute segments)
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

      m_percent = slice.multiplier_percent.to_f > 0 ? slice.multiplier_percent.to_f : 100.0
      multiplier = m_percent / 100.0
      
      # Base money calculation
      slice_money = (duration_mins / 60.0) * hourly_rate * multiplier
      
      # Philippine Labor Law Logic
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

      if slice.night_diff == true
        totals[:night_diff_pay] += (duration_mins / 60.0) * hourly_rate * 0.10
      end
    end

    # 3. Summation
    total_earnings = totals.values.sum
    gross_pay = total_earnings + total_allowance

    # 4. Persistence of the Main Record
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

    # 5. The Deduction "Clean" Call
    # We pass the flags. The logic inside payroll.rb should handle 
    # finding the Master Deduction and creating a snapshot with NO generic note.
    payroll.apply_all_deductions(
      standard_ids: @deduction_ids,
      sss: @sss,
      ph:  @ph,
      pi:  @pi
    )
    
    payroll
  end
end