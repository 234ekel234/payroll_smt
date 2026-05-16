class ReportsController < ApplicationController
  def attendance
    @start_date = Date.parse(params[:start_date].presence || Date.today.beginning_of_month.to_s)
    @end_date = Date.parse(params[:end_date].presence || Date.today.end_of_month.to_s)

    employees = Employee.all
    
    if params[:employee_name].present?
      employees = employees.where("name ILIKE ?", "%#{params[:employee_name]}%")
    end

    if params[:company].present?
      employees = employees.where(company: params[:company])
    end

    @report_data = employees.includes(:daily_time_records).map do |employee|
      # 1. Get existing records in range
      records = employee.daily_time_records.where(date: @start_date..@end_date)
      
      # 2. Calculate Actual Absences
      # Get all dates in range that match the employee's work_days
      expected_work_dates = (@start_date..@end_date).select do |date| 
        employee.work_days.include?(date.strftime("%A"))
      end

      # Dates they actually have a DTR for
      dates_present = records.pluck(:date)

      # Absence = Expected dates minus dates where a record exists
      absence_count = (expected_work_dates - dates_present).count

      # 3. Existing calculations for lates/hours
      total_minutes = records.inject(0) do |sum, r|
        (r.clock_in && r.clock_out) ? sum + ((r.clock_out - r.clock_in) / 60).to_i : sum
      end

      late_freq = records.where("late_minutes > 0").count.to_i

      {
        employee: employee,
        late_count: late_freq,
        total_late_minutes: records.sum { |r| r.late_minutes.to_i }.to_i,
        absence_count: absence_count, # <--- Now dynamic!
        work_hours: (total_minutes / 60.0).round(2),
        ot_hours: (records.sum { |r| r.overtime_minutes.to_i } / 60.0).round(2)
      }
    end

    if params[:late_filter].present?
      @report_data.select! { |d| d[:late_count] >= params[:late_filter].to_i }
    end
  end
end