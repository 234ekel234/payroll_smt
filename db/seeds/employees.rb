# db/seeds/employees.rb

WORK_DAYS = Date::DAYNAMES[1..6] # Monday–Saturday

employees = [
  {
    person_id: "EMP001",
    name: "John Doe",
    company: "Your Company",
    basic_rate: 500,
    allowance_per_day: 100,
    shift_start: Time.zone.parse("09:00"),
    shift_end:   Time.zone.parse("17:00"),
    break_start: Time.zone.parse("012:00"),
    break_end: Time.zone.parse("13:00"),
    schedule: "Regular",
    status_of_employment: "Active",
    landbank_atm: false,
    work_days: WORK_DAYS
  },
  {
    person_id: "EMP002",
    name: "Jane Smith",
    company: "Your Company",
    basic_rate: 500,
    allowance_per_day: 100,
    shift_start: Time.zone.parse("09:00"),
    shift_end:   Time.zone.parse("17:00"),
    break_start: Time.zone.parse("12:00"),
    break_end: Time.zone.parse("13:00"),
    schedule: "Regular",
    status_of_employment: "Active",
    landbank_atm: false,
    work_days: WORK_DAYS
  },
  {
    person_id: "EMP003",
    name: "Mark Johnson",
    company: "Your Company",
    basic_rate: 500,
    allowance_per_day: 100,
    shift_start: Time.zone.parse("18:00"),
    shift_end:   Time.zone.parse("06:00"),
    break_start: Time.zone.parse("00:00"),
    break_end: Time.zone.parse("01:00"),
    schedule: "Regular",
    status_of_employment: "Active",
    landbank_atm: false,
    work_days: WORK_DAYS
  }
]

employees.each do |attrs|
  employee = Employee.find_or_initialize_by(person_id: attrs[:person_id])
  employee.assign_attributes(attrs)
  employee.save!
  puts "Seeded employee: #{employee.person_id} - #{employee.name}"
end

puts "All employees seeded. Total employees: #{Employee.count}"
