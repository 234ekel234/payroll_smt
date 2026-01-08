json.extract! payroll, :id, :employee_id, :start_date, :end_date, :daily_rate, :days_worked, :allowance, :basic_pay, :overtime_pay, :rest_day_pay, :holiday_pay, :night_diff_pay, :gross_pay, :total_deductions, :net_pay, :processed_at, :status, :created_at, :updated_at
json.url payroll_url(payroll, format: :json)
