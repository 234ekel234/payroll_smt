json.extract! daily_time_record, :id, :employee_id, :date, :clock_in, :clock_out, :night_diff_minutes, :overtime_minutes, :abnormal_situation, :created_at, :updated_at
json.url daily_time_record_url(daily_time_record, format: :json)
