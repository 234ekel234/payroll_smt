class PayrollGenerator
  def initialize(start_date:, end_date:, employees:, deduction_ids: [], custom_amounts: {}, sss: false, ph: false, pi: false)
    @start_date     = start_date
    @end_date       = end_date
    @employees      = Array(employees)
    @deduction_ids  = deduction_ids
    # This captures the { "id" => "amount" } hash from your new form inputs
    @custom_amounts = custom_amounts || {}
    @sss            = sss
    @ph             = ph
    @pi             = pi
  end

  def generate!
    Payroll.transaction do
      @employees.each do |employee|
        # Clear existing 'draft' records to allow re-generation
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
    # 1. Calculation Setup
    hourly_rate = employee.basic_rate.to_f / 8.0
    period_dtrs = employee.daily_time_records.where(date: @start_date..@end_date)
    dtr_ids     = period_dtrs.pluck(:id)
    days_present = dtr_ids.count
    total_allowance = (employee.allowance_per_day.to_f * days_present)

    # 2. Process Time Slices
    slices = TimeSlice.where(daily_time_record_id: dtr_ids)
    totals = { basic_pay: 0.0, overtime_pay: 0.0, holiday_pay: 0.0, rest_day_pay: 0.0, night_diff_pay: 0.0 }

    slices.each do |slice|
      duration_mins = slice.minutes.to_f
      next if duration_mins <= 0

      multiplier = (slice.multiplier_percent.to_f > 0 ? slice.multiplier_percent.to_f : 100.0) / 100.0
      slice_money = (duration_mins / 60.0) * hourly_rate * multiplier
      
      # Determine category
      is_holiday = slice.holiday || slice.multiplier_code&.start_with?("RH", "SNWH")
      is_rest    = slice.rest_day || slice.multiplier_code&.split("-")&.include?("RD")

      if is_holiday
        totals[:holiday_pay] += slice_money
      elsif is_rest
        totals[:rest_day_pay] += slice_money
      elsif slice.overtime
        totals[:overtime_pay] += slice_money
      else
        totals[:basic_pay] += slice_money
      end

      if slice.night_diff
        totals[:night_diff_pay] += (duration_mins / 60.0) * hourly_rate * multiplier * 0.10
      end

      slice.update_column(:pay, slice_money.round(2))
    end

    # 3. Final Gross Calculation
    gross_pay = (totals.values.sum + total_allowance).round(2)

    # 4. Create Payroll Record
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
      gross_pay: gross_pay,
      net_pay: gross_pay, # Will be updated after deductions
      status: "draft",
      processed_at: Time.current
    )

    # 5. Apply Selected Deductions
    # First, handle standard deductions with possible custom amount overrides
    apply_custom_deductions(payroll)

    # 6. Trigger Statutory Deductions
    payroll.apply_all_deductions(
      standard_ids: [], # Pass empty since we handled them in apply_custom_deductions
      sss: @sss,
      ph:  @ph,
      pi:  @pi
    )
    
    # Final recalculation ensures net_pay is correct after all injections
    payroll.calculate_final_amounts!
    payroll
  end

  def apply_custom_deductions(payroll)
    @deduction_ids.each do |d_id|
      # Look for a value in the @custom_amounts hash. 
      # Fallback to the default Deduction amount if not provided in the form.
      override_amount = @custom_amounts[d_id.to_s]
      base_deduction = Deduction.find(d_id)
      
      final_amount = override_amount.present? ? override_amount.to_f : base_deduction.amount

      payroll.payroll_deductions.create!(
        deduction_id: d_id,
        amount: final_amount,
        note: "Batch Applied"
      )
    end
  end
end