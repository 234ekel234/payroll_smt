# Define the payroll period
period_start = Date.new(2026, 2, 1)
period_end   = Date.new(2026, 2, 15)

# Your manual data mapping: person_id => [days_worked, net_pay]
# Add your actual data here
payroll_batch = {
  "EMP001" => { days: 11, net: 12500.50 },
  "EMP002" => { days: 10, net: 9800.00 },
  "EMP003" => { days: 12, net: 15200.75 }
}

puts "--- Starting Payroll Seed (Period: #{period_start} to #{period_end}) ---"

payroll_batch.each do |pid, data|
  employee = Employee.find_by(person_id: pid)

  if employee
    # find_or_initialize lets us update existing records or create new ones
    payroll = Payroll.find_or_initialize_by(
      employee: employee,
      start_date: period_start,
      end_date: period_end
    )

    payroll.assign_attributes(
      days_worked:      data[:days],
      net_pay:          data[:net],
      # Calculating rough gross/deductions so the record isn't "empty"
      gross_pay:        data[:net], 
      total_deductions: 0.0,
      status:           "Processed",
      processed_at:     Time.current
    )

    if payroll.save
      puts "✅ Success: [#{pid}] #{employee.name} - Days: #{data[:days]}, Net: #{data[:net]}"
    else
      puts "❌ Error: Could not save payroll for #{pid}: #{payroll.errors.full_messages.join(', ')}"
    end
  else
    puts "⚠️ Warning: Employee with person_id '#{pid}' not found in database. Skipping..."
  end
end

puts "--- Seed Finished: #{Payroll.where(start_date: period_start).count} records processed ---"