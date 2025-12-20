json.extract! employee, :id, :name, :person_id, :company, :status_of_employment, :schedule, :basic_rate, :allowance_per_day, :landbank_atm, :shift_start, :shift_end, :break_start, :break_end, :created_at, :updated_at
json.url employee_url(employee, format: :json)
