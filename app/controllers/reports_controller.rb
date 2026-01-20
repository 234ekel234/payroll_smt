class ReportsController < ApplicationController
  def attendance
    # 1. Capture Date Range (Default to current month)
    @start_date = params[:start_date].presence || Date.today.beginning_of_month.to_s
    @end_date = params[:end_date].presence || Date.today.end_of_month.to_s

    # 2. Filter Employees first (Reduces processing time)
    employees = Employee.all
    
    if params[:employee_name].present?
      employees = employees.where("name ILIKE ?", "%#{params[:employee_name]}%")
    end

    if params[:company].present?
      employees = employees.where(company: params[:company])
    end

    # 3. Build the report data
    # We use .includes(:daily_time_records) to prevent N+1 query issues
    @report_data = employees.includes(:daily_time_records).map do |employee|
      # Scope records to the selected date range
      records = employee.daily_time_records.where(date: @start_date..@end_date)
      
      # Calculate Total Rendered Minutes
      total_minutes = records.inject(0) do |sum, r|
        if r.clock_in && r.clock_out
          sum + ((r.clock_out - r.clock_in) / 60).to_i
        else
          sum
        end
      end

      late_freq = records.where("late_minutes > 0").count.to_i

      # 4. Filter by Late Frequency (optional check before adding to array)
      # If a filter is set, and the employee doesn't meet the threshold, skip them
      if params[:late_filter].present? && late_freq < params[:late_filter].to_i
        next nil
      end

      # 5. Return a hash of data for the view
      {
        employee: employee,
        late_count: late_freq,
        total_late_minutes: records.sum { |r| r.late_minutes.to_i }.to_i,
        absence_count: records.where(abnormal_situation: 'Absence').count.to_i,
        work_hours: (total_minutes / 60.0).round(2),
        ot_hours: (records.sum { |r| r.overtime_minutes.to_i } / 60.0).round(2)
      }
    end.compact # Removes skipped (nil) entries
  end
end