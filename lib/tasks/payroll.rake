namespace :payroll do
  desc "Backfill absent_holiday_pay for payrolls that predate the column (NULL records)"
  task backfill_absent_holiday_pay: :environment do
    # Target all payrolls — absent_holiday_pay defaulted to 0 for pre-migration
    # records so we can't use IS NULL. Recalculating is safe; it's a display column
    # only and does not affect gross_pay (which already includes the amount).
    payrolls = Payroll.all
    puts "Backfilling #{payrolls.count} payrolls..."

    updated = 0
    payrolls.find_each do |payroll|
      employee  = payroll.employee
      dtr_dates = employee.daily_time_records
                          .where(date: payroll.start_date..payroll.end_date)
                          .pluck(:date).to_set

      absent_pay = 0.0
      holidays   = Holiday.where(date: payroll.start_date..payroll.end_date, holiday_type: "regular")

      holidays.each do |holiday|
        next unless employee.work_days.include?(holiday.date.strftime("%A"))
        next if dtr_dates.include?(holiday.date)

        prev = last_work_day_before(holiday.date, employee.work_days)
        next unless prev && dtr_dates.include?(prev)

        absent_pay += employee.basic_rate.to_f
      end

      payroll.update_column(:absent_holiday_pay, absent_pay.round(2))
      updated += 1
    end

    puts "Done. #{updated} payrolls updated."
  end

  def last_work_day_before(date, work_days)
    check = date - 1.day
    14.times do
      return check if work_days.include?(check.strftime("%A"))
      check -= 1.day
    end
    nil
  end
end
