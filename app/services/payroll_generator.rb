class PayrollGenerator
  def initialize(start_date:, end_date:, employees:, deduction_ids: [])
    @start_date    = start_date
    @end_date      = end_date
    @employees     = Array(employees)
    @deduction_ids = deduction_ids # The "on-the-fly" selection from your batch form
  end

  def generate!
    Payroll.transaction do
      @employees.each do |employee|
        # 1. Clear existing 'draft' to avoid duplicates
        Payroll.where(
          employee: employee, 
          start_date: @start_date, 
          end_date: @end_date, 
          status: 'draft'
        ).destroy_all
        
        # 2. Process earnings and create payroll
        payroll = process_employee(employee)

        # 3. Apply the selected deductions "on-the-fly"
        # This will calculate SSS, PhilHealth, etc., based on the gross_pay just created
        payroll.apply_deductions(@deduction_ids) if @deduction_ids.present?
      end
    end
  end

  private

  def process_employee(employee)
    hourly_rate = employee.basic_rate / 8.0
    
    slices = TimeSlice.joins(:daily_time_record)
                      .where(daily_time_records: { 
                        employee_id: employee.id, 
                        date: @start_date..@end_date 
                      })

    totals = {
      basic_pay: 0.0,
      overtime_pay: 0.0,
      holiday_pay: 0.0,
      rest_day_pay: 0.0,
      night_diff_pay: 0.0,
      days_worked: slices.select('daily_time_record_id').distinct.count
    }

    slices.each do |slice|
      slice_total = (slice.minutes / 60.0) * hourly_rate * (slice.multiplier_percent / 100.0)

      if slice.overtime
        totals[:overtime_pay] += slice_total
      elsif slice.holiday
        totals[:holiday_pay] += slice_total
      elsif slice.rest_day
        totals[:rest_day_pay] += slice_total
      else
        totals[:basic_pay] += slice_total
      end

      if slice.night_diff
        totals[:night_diff_pay] += (slice.minutes / 60.0) * hourly_rate * 0.10
      end
    end

    gross_pay = totals[:basic_pay] + totals[:overtime_pay] + totals[:holiday_pay] + totals[:rest_day_pay]

    # Return the created record so we can call apply_deductions on it
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
      # Initialize net_pay as gross; apply_deductions will update this correctly
      net_pay: gross_pay, 
      status: "draft",
      processed_at: Time.current
    )
  end
end