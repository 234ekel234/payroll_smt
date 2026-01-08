# db/seeds.rb

Holiday.destroy_all

puts "Seeding Holidays..."

holidays = [
  # Regular Holidays
  { date: "2026-01-01", name: "New Year's Day", holiday_type: "Regular", applies_to: "all", notes: "Paid holiday for all employees" },
  { date: "2026-05-01", name: "Labor Day", holiday_type: "Regular", applies_to: "all", notes: "Paid holiday for all employees" },
  { date: "2026-12-25", name: "Christmas Day", holiday_type: "Regular", applies_to: "all", notes: "Paid holiday for all employees" },

  # Special Non-Working Holidays
  { date: "2026-02-25", name: "Local Founding Day", holiday_type: "Special Non-Working", applies_to: "staff", notes: "Optional for some employees" },
  { date: "2026-11-30", name: "Company Anniversary", holiday_type: "Special Non-Working", applies_to: "managers", notes: "Only applies to managers" },

  # Example: holiday that falls on rest day (weekend)
  { date: "2026-06-12", name: "Independence Day", holiday_type: "Regular", applies_to: "all", notes: "May fall on weekend" }
]

holidays.each do |h|
  Holiday.create!(h)
end

puts "Holidays seeded successfully!"
