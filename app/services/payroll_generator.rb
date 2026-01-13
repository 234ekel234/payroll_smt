class PayrollGenerator
  def initialize(start_date:, end_date:, employees:)
    @start_date = start_date
    @end_date   = end_date
    @employees  = Array(employees) # Handles both a single employee or a collection
  end

  def generate!
    Payroll.transaction do
      @employees.each do |employee|
        # 1. Guard Clause: Remove existing 'draft' payroll for this period 
        # to allow for re-calculation/overwriting.
        Payroll.where(employee: employee, start_date: @start_date, end_date: @end_date, status: 'draft').destroy_all
        
        # 2. Process individual employee
        process_employee(employee)
      end
    end
  end

  private

  def process_employee(employee)
    hourly_rate = employee.basic_rate / 8.0
    
    # Fetch slices associated with this employee's DTRs within the range
    slices = TimeSlice.joins(:daily_time_record)
                      .where(daily_time_records: { 
                        employee_id: employee.id, 
                        date: @start_date..@end_date 
                      })

    # Initialize totals
    totals = {
      basic_pay: 0.0,
      overtime_pay: 0.0,
      holiday_pay: 0.0,
      rest_day_pay: 0.0,
      night_diff_pay: 0.0,
      days_worked: slices.select('daily_time_record_id').distinct.count
    }

    slices.each do |slice|
      # Base formula: (Mins / 60) * Hourly Rate * (Multiplier / 100)
      slice_total = (slice.minutes / 60.0) * hourly_rate * (slice.multiplier_percent / 100.0)

      # Categorize the pay
      if slice.overtime
        totals[:overtime_pay] += slice_total
      elsif slice.holiday
        totals[:holiday_pay] += slice_total
      elsif slice.rest_day
        totals[:rest_day_pay] += slice_total
      else
        totals[:basic_pay] += slice_total
      end

      # Isolate the Night Diff premium (extra 10%) for display purposes if needed
      if slice.night_diff
        totals[:night_diff_pay] += (slice.minutes / 60.0) * hourly_rate * 0.10
      end
    end

    gross_pay = totals[:basic_pay] + totals[:overtime_pay] + totals[:holiday_pay] + totals[:rest_day_pay]

    # Create the record
    Payroll.create!(
      employee: employee,
      start_date: @start_date,
      end_date: @end_date,
      daily_rate: employee.basic_rate,
      days_worked: totals[:days_worked],
      basic_pay: totals[:basic_pay],
      overtime_pay: totals[:overtime_pay],
      holiday_pay: totals[:holiday_pay],
      rest_day_pay: totals[:rest_day_pay],
      night_diff_pay: totals[:night_diff_pay],
      gross_pay: gross_pay,
      net_pay: gross_pay, # Deductions logic to be added later
      status: "draft",
      processed_at: Time.current
    )
  end
end